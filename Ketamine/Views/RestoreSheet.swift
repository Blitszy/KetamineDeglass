import SwiftUI

struct RestoreSheet: View {
    @EnvironmentObject private var store: GestaltStore
    @Environment(\.dismiss) private var dismiss

    @State private var done = false
    @State private var showConfirm = false
    @State private var isRestoring = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        if store.backup.hasBackup {
                            Card {
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
                                if let info = store.backup.info {
                                    Label("Backup from \(info.createdAt.formatted(date: .abbreviated, time: .shortened)) · \(ByteCountFormatter.string(fromByteCount: Int64(info.byteCount), countStyle: .file))", systemImage: "clock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }

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
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Theme.surface)
                                    )
                            } else {
                                ActionButton(
                                    title: "Restore",
                                    systemImage: "arrow.uturn.backward",
                                    destructive: true,
                                    isBusy: isRestoring,
                                    action: { showConfirm = true }
                                )
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
        .confirmationDialog(
            "Restore original MobileGestalt",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button("Restore", role: .destructive) {
                runRestore()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The pristine backup file will be written back, reversing every tweak. Keep the device charged and do not close the app.")
        }
    }

    private func runRestore() {
        errorMessage = nil
        isRestoring = true
        Task {
            do {
                _ = try await store.restore()
                isRestoring = false
                done = true
            } catch {
                isRestoring = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
