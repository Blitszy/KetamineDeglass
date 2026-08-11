import SwiftUI
import LiquidGlass

struct SettingsView: View {
    @EnvironmentObject private var store: GestaltStore

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
                    VStack(spacing: 16) {
                        header
                        aboutSection
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
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 10) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Text("Ketamine")
                .font(.title.weight(.bold))
            Text("MobileGestalt Editor · v\(version)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .glass(style: .card, tint: Theme.accent.opacity(0.10), cornerRadius: 24)
        .padding(.top, 8)
    }

    // MARK: About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("ABOUT")
            Text("Ketamine patches the live MobileGestalt cache on-device using the MobileHouseArrest exploit, no computer, plist dumps, or restore required.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .glass(style: .card, tint: Theme.accent.opacity(0.05))
    }

    // MARK: Backup

    private var backupSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("BACKUP")
            HStack {
                Image(systemName: store.backup.hasBackup ? "checkmark.shield.fill" : "shield.slash")
                    .font(.title2)
                    .foregroundStyle(Theme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.backup.hasBackup ? "Backup exists" : "No backup yet")
                        .font(.headline)
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
        .padding(14)
        .glass(style: .card, tint: Theme.accent.opacity(0.05))
    }

    // MARK: Credits

    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("CREDITS")
            creditLink(icon: "person.fill",
                       name: "Nouvborne",
                       role: "Ketamine developer",
                       url: URL(string: "https://github.com/Nouvborne")!)
            creditLink(icon: "lock.shield.fill",
                       name: "0xjohnnydev",
                       role: "PoC exploit — class-13 container access",
                       url: URL(string: "https://github.com/0xjohnnydev")!)
            creditLink(icon: "globe",
                       name: "jailbreak.party",
                       role: "Web respringer",
                       url: URL(string: "https://jailbreak.party")!)
        }
        .padding(14)
        .glass(style: .card, tint: Theme.accent.opacity(0.05))
    }

    // MARK: Disclaimer

    private var disclaimer: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("DISCLAIMER")
            Text("Use at your own risk. Ketamine relies on an exploit that is patched on newer iOS builds and modifies system files. Always keep the pristine backup, keep your device charged during apply/restore, and be ready to restore your device in Finder if something goes wrong. Supported: iOS 18.0 – 27.0 beta 4 (build 24A5390f).")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .glass(style: .card, tint: Theme.accent.opacity(0.05))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
    }

    private func creditLink(icon: String, name: String, role: String, url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(Theme.accent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                    Text(role)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}
