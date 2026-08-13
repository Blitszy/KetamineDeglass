import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GestaltStore

    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var activeSheet: ActiveSheet?

    private var grouped: [(TweakCategory, [Tweak])] {
        TweakCategory.allCases.compactMap { category in
            let items = store.tweaks.filter { $0.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        header
                        betaNotice
                        ForEach(grouped, id: \.0) { category, tweaks in
                            section(category, tweaks: tweaks)
                        }
                        footnotes
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .safeAreaInset(edge: .bottom) { dock }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .restore: RestoreSheet()
            }
        }
        .alert("Could not save changes", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 6) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            Text("Ketamine")
                .font(.title.weight(.bold))
            Text("MobileGestalt Editor")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: Beta notice

    private var betaNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.subheadline)
                .foregroundStyle(Theme.danger)
            VStack(alignment: .leading, spacing: 2) {
                Text("Early Beta")
                    .font(.subheadline.weight(.semibold))
                Text("This is a very early build with bugs and glitches. Everything will be fixed in future updates.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.surface)
        )
    }

    // MARK: Section

    private func section(_ category: TweakCategory, tweaks: [Tweak]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: category.rawValue)
            RowGroup {
                ForEach(Array(tweaks.enumerated()), id: \.element.id) { index, tweak in
                    TweakRow(tweak: tweak)
                    if index < tweaks.count - 1 {
                        RowDivider()
                    }
                }
            }
        }
    }

    // MARK: Footnotes

    private var footnotes: some View {
        VStack(spacing: 6) {
            Text("Modifying MobileGestalt can cause boot loops or data loss on unsupported devices. Only proceed on supported OS versions and keep your device plugged in.")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("Revert everything at any time from the Restore button below, or restore your device in Finder while the backup file still exists.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }

    // MARK: Dock

    private var dock: some View {
        HStack(spacing: 12) {
            ActionButton(
                title: store.enabledCount > 0 ? "Save \(store.enabledCount)" : "Save Changes",
                systemImage: "checkmark",
                isBusy: store.isBusy,
                disabled: store.enabledCount == 0,
                action: saveChanges
            )

            Button {
                guard store.backup.hasBackup else { return }
                activeSheet = .restore
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.headline)
                    .foregroundStyle(Theme.danger)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Theme.danger.opacity(0.10)))
            }
            .disabled(!store.backup.hasBackup)
            .opacity(store.backup.hasBackup ? 1 : 0.35)
        }
        .padding(8)
        .appGlass(shape: .sheet)
        .padding(.horizontal, 16)
    }

    // MARK: Actions

    private func saveChanges() {
        Task {
            do {
                _ = try await store.apply()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                RespringHelper.respring()
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

// MARK: - Active sheet

enum ActiveSheet: Identifiable {
    case restore

    var id: Int { hashValue }
}

// MARK: - Tweak row

struct TweakRow: View {
    @EnvironmentObject private var store: GestaltStore
    let tweak: Tweak

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                CategoryBadge(symbol: tweak.symbol)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(tweak.title)
                            .font(.subheadline.weight(.medium))
                        if tweak.isRisky {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(Theme.danger)
                        }
                    }
                    Text(tweak.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 8)
                Toggle("", isOn: store.binding(for: tweak.id))
                    .labelsHidden()
                    .tint(Theme.accent)
            }
            .padding(12)

            if tweak.isEnabled {
                RowDivider()
                VStack(spacing: 10) {
                    if let note = tweak.notes {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(Theme.danger)
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    if let detail = tweak.detail {
                        switch detail {
                        case .picker(let options):
                            Picker("", selection: store.pickerBinding(for: tweak.id)) {
                                ForEach(Array(options.enumerated()), id: \.offset) { idx, opt in
                                    Text(opt).tag(idx)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        case .textField(let placeholder, let keyboard):
                            TextField(placeholder, text: store.textBinding(for: tweak.id))
                                .keyboardType(keyboard == .numeric ? .numberPad : .default)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(.secondarySystemBackground))
                                )
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.3), value: tweak.isEnabled)
    }
}
