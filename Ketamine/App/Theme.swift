import SwiftUI
import LiquidGlass

// MARK: - Palette

enum Theme {
    static let accent = Color(.systemBlue)
    static let danger = Color(.systemRed)

    static let background = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.99, blue: 1.0),
            Color(red: 0.91, green: 0.94, blue: 1.0),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let glowBlue = Color(red: 0.40, green: 0.68, blue: 1.0).opacity(0.30)
    static let glowViolet = Color(red: 0.58, green: 0.48, blue: 1.0).opacity(0.26)
}

// MARK: - Glass background

/// Soft light backdrop with gentle color blooms so the glass surfaces have
/// something to refract while keeping the app airy and simple.
struct GlassBackground: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Circle()
                .fill(Theme.glowBlue)
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: 170, y: -320)
            Circle()
                .fill(Theme.glowViolet)
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: -180, y: 220)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Category badge

struct CategoryBadge: View {
    let category: TweakCategory
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Theme.accent)
            .frame(width: 38, height: 38)
            .glass(style: .toolbar, tint: Theme.accent.opacity(0.14))
    }
}
