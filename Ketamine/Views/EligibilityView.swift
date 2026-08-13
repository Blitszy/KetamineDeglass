import SwiftUI
import UIKit

struct EligibilityView: View {
    @ObservedObject private var manager = EligibilityManager.shared

    @State private var isBusy = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var reachable = false

    private var isSupported: Bool {
        reachable
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        header
                        if !isSupported {
                            unavailableNotice
                        }
                        optionsSection
                        actionSection
                        footnotes
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                .scrollDismissesKeyboard(.interactively)

                if isBusy {
                    ProgressOverlay(message: "Applying eligibility…")
                }
            }
            .navigationTitle("Eligibility")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                reachable = EligibilityManager.isReachable()
            }
        }
        .alert("Something went wrong", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "checklist")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 56, height: 56)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color(.tertiarySystemFill)))
            Text("Eligibility")
                .font(.title.weight(.bold))
            Text("Force-approve Apple Intelligence eligibility on iOS 27")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: Unavailable notice

    private var unavailableNotice: some View {
        Card {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(Theme.danger)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Not available on this device")
                        .font(.subheadline.weight(.semibold))
                    Text("This iOS build's containermanager refuses bad_query access to the eligibility container (containermanager sandbox), so eligibility can't be written here. Use the Apple Intelligence tweak + Device Spoof in Tweaks instead — on iOS 27 this needs the system to extend the systemgroup.com.apple.eligibility path.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    // MARK: Options

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "Domains")
            Card {
                Toggle(isOn: $manager.enableGreyMatter) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apple Intelligence")
                            .font(.subheadline.weight(.semibold))
                        Text("GREYMATTER domain — generative model eligibility.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(Theme.accent)

                Divider()

                Toggle(isOn: $manager.enableCalcium) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("China Cellular")
                            .font(.subheadline.weight(.semibold))
                        Text("CALCIUM domain — unsets the China-cellular restriction.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(Theme.accent)
            }
            Text("Domains are merged into the existing eligibility.plist — nothing else is touched. Disabling a toggle removes just that domain. The original file is backed up on first apply.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
        }
    }

    // MARK: Actions

    @ViewBuilder
    private var actionSection: some View {
        if isSupported {
            Card {
                ActionButton(
                    title: "Apply",
                    systemImage: "checkmark",
                    isBusy: isBusy,
                    action: apply
                )

                TonalButton(
                    title: "Reset",
                    systemImage: "arrow.clockwise",
                    tint: Theme.danger,
                    action: reset
                )
                .disabled(isBusy)
            }
        }
    }

    // MARK: Footnotes

    private var footnotes: some View {
        VStack(spacing: 6) {
            Text("For the full Apple Intelligence workflow, also enable the Apple Intelligence tweak and spoof to an AI-capable model in Tweaks.")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("Reset restores the eligibility.plist captured on your first apply.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }

    // MARK: Actions

    private func apply() {
        guard isSupported, !isBusy else { return }
        isBusy = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try manager.apply()
                DispatchQueue.main.async {
                    isBusy = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    RespringHelper.respring()
                }
            } catch {
                DispatchQueue.main.async {
                    isBusy = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }

    private func reset() {
        guard isSupported, !isBusy else { return }
        isBusy = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try manager.reset()
                DispatchQueue.main.async {
                    isBusy = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } catch {
                DispatchQueue.main.async {
                    isBusy = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}
