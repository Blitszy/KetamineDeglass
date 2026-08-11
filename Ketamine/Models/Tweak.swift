import Foundation

// MARK: - Categories

enum TweakCategory: String, CaseIterable, Identifiable {
    case display = "Display"
    case system = "System"
    case liquidGlass = "Liquid Glass"
    case ipad = "iPad"
    case ai = "Intelligence"

    var id: String { rawValue }
}

// MARK: - Values

/// A plist value that can be written into CacheExtra.
enum MGValue: Equatable {
    case int(Int)
    case string(String)
    case intArray([Int])

    var plistObject: Any {
        switch self {
        case .int(let v): return v
        case .string(let v): return v
        case .intArray(let v): return v
        }
    }
}

// MARK: - Modifications

struct GestaltModification: Equatable {
    let key: String
    /// When set, `value` is written into `key[subkey]` instead of `key`.
    let subkey: String?
    let value: MGValue
    /// Marks the modification driven by a `.picker` detail so only that
    /// value is swapped for the selected option.
    var isPicker: Bool = false
}

// MARK: - Detail (inline editors)

enum TweakDetail: Equatable {
    case picker(options: [String])
    case textField(placeholder: String, keyboard: TextFieldKind)
}

enum TextFieldKind: Equatable {
    case plain
    case numeric
}

// MARK: - Tweak

struct Tweak: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let category: TweakCategory
    let symbol: String
    let isRisky: Bool
    /// Optional per-tweak notes shown under the row when risky.
    let notes: String?

    var isEnabled: Bool = false
    var detail: TweakDetail?
    var selectedIndex: Int = 0
    var textValue: String = ""
    /// For `.picker` details: the int values that map 1:1 to `options`.
    var pickerValues: [Int] = []

    /// Special flag for iPadOS: requires the CacheData binary patch.
    var requiresCacheDataPatch: Bool = false

    let modifications: [GestaltModification]
}
