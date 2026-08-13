import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: GestaltStore
    @AppStorage("pbHash") private var pbHash: String = ""

    @State private var detectingHash = false
    @State private var showHashError = false
    @State private var hashErrorMessage = ""

    private var version: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        header
                        aboutSection
                        posterBoardSection
                        backupSection
                        creditsSection
                        disclaimer
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Could not detect PosterBoard hash", isPresented: $showHashError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(hashErrorMessage)
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
            Text("MobileGestalt Editor · v\(version)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: About

    private var aboutSection: some View {
        Card {
            SectionTitle(title: "About")
            Text("Ketamine patches the live MobileGestalt cache on-device using the MobileHouseArrest exploit, no computer, plist dumps, or restore required.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: PosterBoard hash

    private var posterBoardSection: some View {
        Card {
            SectionTitle(title: "PosterBoard App Hash")
            Text("The UUID of PosterBoard's data container, used to inject tendies. Auto-detected on-device via bad_query, no computer needed.")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("PosterBoard App Hash", text: $pbHash)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            HStack(spacing: 10) {
                ActionButton(
                    title: "Detect On-Device",
                    isBusy: detectingHash,
                    disabled: detectingHash,
                    action: detectPosterBoardHash
                )

                if !pbHash.isEmpty {
                    Button {
                        pbHash = ""
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color(.tertiarySystemFill)))
                    }
                }
            }
            if !BadQuery.isAvailable {
                Label("bad_query unavailable on this iOS version — automatic detection won't work.", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Backup

    private var backupSection: some View {
        Card {
            SectionTitle(title: "Backup")
            HStack(spacing: 10) {
                Image(systemName: store.backup.hasBackup ? "checkmark.shield.fill" : "shield.slash")
                    .font(.title2)
                    .foregroundStyle(store.backup.hasBackup ? Theme.accent : Color(.tertiaryLabel))
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.backup.hasBackup ? "Backup exists" : "No backup yet")
                        .font(.subheadline.weight(.medium))
                    if let info = store.backup.info {
                        Text("Created \(info.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("SHA-256 \(info.sha256.prefix(16))…")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .textSelection(.enabled)
                    } else {
                        Text("Created automatically on your first apply.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: Credits

    private var creditsSection: some View {
        Card(padding: 4) {
            VStack(alignment: .leading, spacing: 0) {
                SectionTitle(title: "Credits")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                RowDivider(inset: 34)
                creditLink(icon: "person.fill",
                           name: "Nouvborne",
                           role: "Ketamine developer",
                           url: URL(string: "https://github.com/Nouvborne")!)
                RowDivider(inset: 34)
                creditLink(icon: "lock.shield.fill",
                           name: "0xjohnnydev",
                           role: "PoC exploit — class-13 container access",
                           url: URL(string: "https://github.com/0xjohnnydev")!)
                RowDivider(inset: 34)
                creditLink(icon: "wrench.and.screwdriver.fill",
                           name: "leminlimez",
                           role: "Pocket-Poster",
                           url: URL(string: "https://github.com/leminlimez")!)
                RowDivider(inset: 34)
                creditLink(icon: "lock.shield.fill",
                           name: "forcequitOS",
                           role: "bad_query sandbox escape",
                           url: URL(string: "https://github.com/forcequitOS/bad_query")!)
                RowDivider(inset: 34)
                creditLink(icon: "globe",
                           name: "jailbreak.party",
                           role: "Web respringer",
                           url: URL(string: "https://jailbreak.party")!)
            }
        }
    }

    // MARK: Disclaimer

    private var disclaimer: some View {
        Card {
            SectionTitle(title: "Disclaimer")
            Text("Use at your own risk. Ketamine relies on an exploit that is patched on newer iOS builds and modifies system files. Always keep the pristine backup, keep your device charged during apply/restore, and be ready to restore your device in Finder if something goes wrong. Supported: iOS 18.0 – 27.0 beta 4 (build 24A5390f).")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private func creditLink(icon: String, name: String, role: String, url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(role)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private func detectPosterBoardHash() {
        guard !detectingHash else { return }
        detectingHash = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let hash = try BadQuery.findPosterBoardHash()
                let trimmed = hash.trimmingCharacters(in: .whitespacesAndNewlines)
                DispatchQueue.main.async {
                    pbHash = trimmed
                    detectingHash = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } catch {
                DispatchQueue.main.async {
                    detectingHash = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    hashErrorMessage = error.localizedDescription
                    showHashError = true
                }
            }
        }
    }
}
