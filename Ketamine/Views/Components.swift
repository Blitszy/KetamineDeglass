import SwiftUI

// MARK: - Native glass (restrained — used for the dock only)

enum AppGlassShape {
    case card
    case sheet

    var cornerRadius: CGFloat {
        switch self {
        case .card: return 16
        case .sheet: return 24
        }
    }
}

extension View {
    /// Applies the native Liquid Glass material on iOS 26+ (guarded) with a
    /// matching ultra-thin material fallback for iOS 17/18.
    @ViewBuilder
    func appGlass(shape: AppGlassShape = .card, tint: Color = .clear) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(
                Glass.regular.tint(tint),
                in: RoundedRectangle(cornerRadius: shape.cornerRadius, style: .continuous)
            )
        } else {
            background(
                RoundedRectangle(cornerRadius: shape.cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Surfaces

/// A single rounded surface (Settings-style card).
struct Card<Content: View>: View {
    var padding: CGFloat = 14
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.surface)
            )
    }
}

/// Rows grouped in one rounded surface, separated by hairline dividers.
struct RowGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.surface)
            )
    }
}

/// Hairline separator between grouped rows.
struct RowDivider: View {
    var inset: CGFloat = 54

    var body: some View {
        Rectangle()
            .fill(Theme.separator)
            .frame(height: 0.5)
            .padding(.leading, inset)
    }
}

// MARK: - Section title

struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.4)
            .padding(.leading, 4)
    }
}

// MARK: - Buttons

/// Primary filled button — accent by default, danger when destructive.
struct ActionButton: View {
    let title: String
    var systemImage: String? = nil
    var destructive: Bool = false
    var isBusy: Bool = false
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isBusy {
                    ProgressView()
                        .tint(.white)
                }
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(destructive ? Theme.danger : Theme.accent)
            )
        }
        .buttonStyle(.plain)
        .disabled(disabled || isBusy)
        .opacity(disabled || isBusy ? 0.4 : 1)
    }
}

/// Quiet tonal button — tinted text on a faint tinted fill.
struct TonalButton: View {
    let title: String
    var systemImage: String? = nil
    var tint: Color = Theme.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.10))
            )
        }
        .buttonStyle(.plain)
    }
}

/// Plain text button — no background at all.
struct TextButton: View {
    let title: String
    var systemImage: String? = nil
    var tint: Color = Theme.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress overlay

struct ProgressOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(26)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.black.opacity(0.78))
            )
        }
        .transition(.opacity)
    }
}
