import SwiftUI
import UIKit
import SafariServices

/// Press-and-hold confirmation control used for every destructive action so
/// nothing is ever applied by a single tap.
struct HoldToConfirmButton: View {
    let title: String
    let systemImage: String
    let holdDuration: TimeInterval
    let tint: AnyShapeStyle
    let action: () -> Void

    @State private var holding = false
    @State private var progress: CGFloat = 0

    private let feedback = UIImpactFeedbackGenerator(style: .medium)

    init(_ title: String,
         systemImage: String = "hand.point.up.left.fill",
         holdDuration: TimeInterval = 1.5,
         tint: AnyShapeStyle = AnyShapeStyle(Theme.accent),
         action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.holdDuration = holdDuration
        self.tint = tint
        self.action = action
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.headline)
            Text(title)
                .font(.headline)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(tint)
        )
        .scaleEffect(holding ? 1.02 : 1.0)
        .animation(.spring(duration: 0.25), value: holding)
        .overlay {
            GeometryReader { geo in
                if holding {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(.white.opacity(0.16))
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(.white.opacity(0.34))
                            .frame(width: geo.size.width * progress)
                    }
                    .padding(2)
                    .allowsHitTesting(false)
                }
            }
            .allowsHitTesting(false)
        }
        .gesture(
            LongPressGesture(minimumDuration: holdDuration)
                .onChanged { _ in holding = true }
                .onEnded { _ in
                    holding = false
                    progress = 0
                    feedback.impactOccurred()
                    action()
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    holding = true
                    withAnimation(.linear(duration: holdDuration)) { progress = 1 }
                }
                .onEnded { _ in
                    holding = false
                    withAnimation(.linear(duration: 0.1)) { progress = 0 }
                }
        )
    }
}

// MARK: - In-app Safari

/// Wraps SFSafariViewController so the web respringer opens in a Safari
/// popup inside the app instead of launching the standalone browser.
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
