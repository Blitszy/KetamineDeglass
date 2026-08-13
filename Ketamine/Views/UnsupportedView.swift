import SwiftUI

struct UnsupportedView: View {
    let reason: String

    private var os: DeviceCompatibility.OSInfo {
        DeviceCompatibility.currentInfo
    }

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 60)

                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    VStack(spacing: 8) {
                        Text("Ketamine")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        Text("Unsupported device")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(Theme.danger)
                        Text(reason)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )

                    VStack(spacing: 6) {
                        InfoRow(label: "iOS version", value: "\(os.version.majorVersion).\(os.version.minorVersion).\(os.version.patchVersion)")
                        InfoRow(label: "Build", value: os.build ?? "unknown")
                        InfoRow(label: "Verified up to", value: "27.0 beta 4 · 24A5390f")
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )

                    Text("Newer builds have patched the MobileGestalt container access. You can still build and inspect the app, but it will not modify anything.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .textSelection(.enabled)
        }
        .font(.subheadline)
    }
}
