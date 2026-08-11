import SwiftUI
import LiquidGlass

struct RestoreSheet: View {
    @EnvironmentObject private var store: GestaltStore
    @Environment(\.dismiss) private var dismiss

    @State private var isRestoring = false
    @State private var done = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        if store.backupInfo.map({ $0.sha256 }) != nil {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Theme.accent)
                                    Text("Restore original MobileGestalt")
                                        .font(.headline)
                                }
                                Text("The exact untouched file captured on your first apply will be written back, reversing every tweak — including the iPadOS binary patch.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let info = store.backupInfo {
                                    Label("Backup from \(info.createdAt.formatted(date: .abbreviated, time: .shortened)) · \(ByteCountFormatter.string(fromByteCount: Int64(info.byteCount), countStyle: .file))", systemImage: "clock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding(14)
                            .glass(style: .card, tint: Theme.accent.opacity(0.08))

                            if done {
                                Label("Restored. Reboot to complete.", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                                    .padding(.vertical, 8)
                            } else if let errorMessage {
                                Label(errorMessage, systemImage: "xmark.octagon.fill")
                                    .font(.caption)
                                    .foregroundStyle(Theme.danger)
                                    .padding(14)
                                    .glass(style: .card, tint: Theme.danger.opacity(0.08))
                            } else {
                                HoldToConfirmButton("Hold to Restore", systemImage: "arrow.uturn.backward",
                                                    holdDuration: 1.6, tint: AnyShapeStyle(Theme.danger)) {
                                    runRestore()
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Restore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func runRestore() {
        isRestoring = true
        errorMessage = nil
        Task {
            do {
                _ = try await store.restore()
                done = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isRestoring = false
        }
    }
}
