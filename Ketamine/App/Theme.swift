import SwiftUI

// MARK: - Palette

enum Theme {
    /// The single accent color used across the app.
    static let accent = Color(.systemBlue)

    /// Reserved for destructive actions only.
    static let danger = Color(.systemRed)

    /// Rounded surface used for cards and grouped rows.
    static let surface = Color(.secondarySystemGroupedBackground)

    /// Hairline separator between grouped rows.
    static let separator = Color(.separator)
}

// MARK: - Background

/// Simple monochrome grouped background.
struct GlassBackground: View {
    var body: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }
}

// MARK: - Category badge

struct CategoryBadge: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(width: 30, height: 30)
            .background(Circle().fill(Color(.tertiarySystemFill)))
    }
}
