import SwiftUI
import LiquidGlass

struct HomeView: View {
    @EnvironmentObject private var store: GestaltStore

    @State private var showSavedAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var activeSheet: ActiveSheet?

    private let respringURL = URL(string: "https://jailbreak.party/respring.html")!

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
                    VStack(spacing: 16) {
                        header
                        backupRow
                        ForEach(grouped, id: \.0) { category, tweaks in
                            section(category, tweaks: tweaks)
                        }
                        footnotes
                    }
                    .padding(.horizontal, 16)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .safeAreaInset(edge: .bottom) { dock }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .restore: RestoreSheet()
            case .safari: SafariView(url: respringURL)
            }
        }
        .alert("Changes saved", isPresented: $showSavedAlert) {
            Button("Respring") { activeSheet = .safari }
            Button("OK", role: .cancel) {}
        } message: {
            Text("All enabled tweaks were written to the MobileGestalt cache. Respring or reboot to apply them.")
        }
        .alert("Could not save changes", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 14) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text("Ketamine")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("MobileGestalt Editor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if store.enabledCount > 0 {
                Text("\(store.enabledCount) on")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glass(style: .toolbar, tint: Theme.accent.opacity(0.18))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glass(style: .card, tint: Theme.accent.opacity(0.10), cornerRadius: 24)
    }

    // MARK: Backup row

    private var backupRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.slash")
                .font(.title2)
                .foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Early Beta!")
                    .font(.headline)
                Text("This is very early (mostly AI made UI) and contain bugs and glitches! I'll fix everything (and change this ugly UI) in future updates!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .glass(style: .card, tint: Theme.accent.opacity(0.08))
    }

    // MARK: Section

    private func section(_ category: TweakCategory, tweaks: [Tweak]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.rawValue.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.leading, 6)
            VStack(spacing: 10) {
                ForEach(tweaks) { tweak in
                    TweakRow(tweak: tweak)
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
        VStack(spacing: 10) {
            Button {
                saveChanges()
            } label: {
                HStack(spacing: 8) {
                    if store.isBusy {
                        ProgressView()
                            .tint(Theme.accent)
                    }
                    Image(systemName: "checkmark.circle.fill")
                    Text(store.enabledCount > 0 ? "Save \(store.enabledCount) Changes" : "Save Changes")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(Theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .glass(style: .button, tint: Theme.accent.opacity(0.18), cornerRadius: 14)
            }
            .disabled(store.enabledCount == 0 || store.isBusy)
            .opacity(store.enabledCount == 0 || store.isBusy ? 0.5 : 1)

            Button {
                guard store.backup.hasBackup else { return }
                activeSheet = .restore
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Restore")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(Theme.danger)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .glass(style: .button, tint: Theme.danger.opacity(0.10), cornerRadius: 14)
            }
            .disabled(!store.backup.hasBackup)
            .opacity(store.backup.hasBackup ? 1 : 0.4)
        }
        .padding(14)
        .glass(style: .sheet, tint: Theme.accent.opacity(0.06))
    }

    // MARK: Actions

    private func saveChanges() {
        Task {
            do {
                _ = try await store.apply()
                showSavedAlert = true
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
    case safari

    var id: Int { hashValue }
}

// MARK: - Tweak row

struct TweakRow: View {
    @EnvironmentObject private var store: GestaltStore
    let tweak: Tweak

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                CategoryBadge(category: tweak.category, symbol: tweak.symbol)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(tweak.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
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
                Spacer()
                Toggle("", isOn: store.binding(for: tweak.id))
                    .labelsHidden()
                    .tint(Theme.accent)
            }

            if tweak.isEnabled {
                VStack(spacing: 10) {
                    if let note = tweak.notes {
                        Label(note, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(Theme.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Theme.danger.opacity(0.08))
                            )
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
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Theme.accent.opacity(0.06))
                                )
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .glass(style: .card, tint: Theme.accent.opacity(0.05))
        .animation(.spring(duration: 0.3), value: tweak.isEnabled)
    }
}
