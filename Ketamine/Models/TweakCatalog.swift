import Foundation

/// All tweaks in this app rely exclusively on the MobileGestalt cache —
/// the same keys Nugget writes. Keys are written under `CacheExtra`.
enum TweakCatalog {

    static let all: [Tweak] = [
        // MARK: Display
        Tweak(
            id: "dynamic-island",
            title: "Dynamic Island",
            subtitle: "Spoof device subtype to a Dynamic Island model.",
            category: .display,
            symbol: "rectangle.inset.filled.and.person.filled",
            isRisky: false,
            notes: nil,
            detail: .picker(options: [
                "14 Pro · 2436",
                "15 Pro · 2556",
                "15 Pro Max · 2796",
                "16 Pro · 2622",
                "16 Pro Max · 2868",
                "iPhone 17 · 2736",
            ]),
            selectedIndex: 1,
            pickerValues: [2436, 2556, 2796, 2622, 2868, 2736],
            modifications: [
                GestaltModification(key: "oPeik/9e8lQWMszEjbPzng",
                                    subkey: "ArtworkDeviceSubType",
                                    value: .int(2556),
                                    isPicker: true),
                GestaltModification(key: "YlEtTtHlNesRBMal1CqRaA",
                                    subkey: nil,
                                    value: .int(1)),
            ]
        ),
        Tweak(
            id: "supports-dynamic-island",
            title: "Dynamic Island (Alternate)",
            subtitle: "Force the Dynamic Island capability bit directly.",
            category: .display,
            symbol: "rectangle.inset.filled",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "YlEtTtHlNesRBMal1CqRaA",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "model-name",
            title: "Device Model Name",
            subtitle: "Change the model name shown in Settings.",
            category: .display,
            symbol: "iphone",
            isRisky: false,
            notes: nil,
            detail: .textField(placeholder: "Custom model name", keyboard: .plain),
            modifications: [
                GestaltModification(key: "oPeik/9e8lQWMszEjbPzng",
                                    subkey: "ArtworkDeviceProductDescription",
                                    value: .string(""))
            ]
        ),
        Tweak(
            id: "aod",
            title: "Always-On Display",
            subtitle: "Enable Always-On Display support.",
            category: .display,
            symbol: "sun.max.fill",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "2OOJf1VhaM7NxfRok3HbWQ",
                                    subkey: nil, value: .int(1)),
                GestaltModification(key: "j8/Omm6s1lsmTDFsXjsBfA",
                                    subkey: nil, value: .int(1)),
            ]
        ),
        Tweak(
            id: "aod-vibrancy",
            title: "AOD Vibrancy",
            subtitle: "Enable the Always-On Display vibrancy effect.",
            category: .display,
            symbol: "sparkles",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "ykpu7qyhqFweVMKtxNylWA",
                                    subkey: nil, value: .int(1))
            ]
        ),

        // MARK: System
        Tweak(
            id: "boot-chime",
            title: "Boot Chime",
            subtitle: "Enable the macOS-style boot chime on startup.",
            category: .system,
            symbol: "music.note",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "QHxt+hGLaBPbQJbXiUJX3w",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "charge-limit",
            title: "Charge Limit",
            subtitle: "Enable the 80% charge limit setting.",
            category: .system,
            symbol: "battery.75percent",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "37NVydb//GP/GrhuTN+exg",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "collision-sos",
            title: "Collision SOS",
            subtitle: "Enable the Crash Detection menu.",
            category: .system,
            symbol: "car.side.fill",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "HCzWusHQwZDea6nNhaKndw",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "tap-to-wake",
            title: "Tap to Wake",
            subtitle: "Enable Tap to Wake (useful on iPhone SE).",
            category: .system,
            symbol: "hand.tap.fill",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "yZf3GTRMGTuwSV/lD7Cagw",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "iphone-16-settings",
            title: "iPhone 16 Settings",
            subtitle: "Reveal the Camera Control settings panes.",
            category: .system,
            symbol: "button.programmable",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "CwvKxM2cEogD3p+HYgaW0Q",
                                    subkey: nil, value: .int(1)),
                GestaltModification(key: "oOV1jhJbdV3AddkcCg0AEA",
                                    subkey: nil, value: .int(1)),
            ]
        ),
        Tweak(
            id: "parallax",
            title: "Disable Wallpaper Parallax",
            subtitle: "Turn off the wallpaper depth/parallax effect.",
            category: .system,
            symbol: "square.3.layers.3d.slash",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "UIParallaxCapability",
                                    subkey: nil, value: .int(0))
            ]
        ),
        Tweak(
            id: "stage-manager",
            title: "Stage Manager",
            subtitle: "Advertise Stage Manager support.",
            category: .system,
            symbol: "macwindow",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "qeaj75wk3HF4DwQ8qbIi7g",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "shutter",
            title: "Region Restrictions",
            subtitle: "Spoof region to lift shutter-sound restrictions.",
            category: .system,
            symbol: "camera.aperture",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "h63QSdBCiT/z0WU6rdQv6Q",
                                    subkey: nil, value: .string("US")),
                GestaltModification(key: "zHeENZu+wbg7PUprwNwBWg",
                                    subkey: nil, value: .string("LL/A")),
            ]
        ),
        Tweak(
            id: "pencil",
            title: "Apple Pencil Settings",
            subtitle: "Reveal the Apple Pencil settings tab.",
            category: .system,
            symbol: "pencil.tip",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "yhHcB0iH0d1XzPO/CFd3ow",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "action-button",
            title: "Action Button Settings",
            subtitle: "Reveal the Action Button settings tab.",
            category: .system,
            symbol: "button.horizontal.top.press.fill",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "cT44WE1EohiwRzhsZ8xEsw",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "internal-storage",
            title: "Internal Storage",
            subtitle: "Expose internal storage capacity.",
            category: .system,
            symbol: "internaldrive.fill",
            isRisky: true,
            notes: "Risky on some devices, mainly iPads.",
            modifications: [
                GestaltModification(key: "LBJfwOEzExRxzlAnSuI7eg",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "internal-install",
            title: "Internal Install",
            subtitle: "Mark the build as internal (Metal HUD anywhere).",
            category: .system,
            symbol: "wrench.and.screwdriver.fill",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "EqrsVvjcYDdxHBiQmGhAWw",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "srd",
            title: "Security Research Device",
            subtitle: "Enable Security Research Device mode.",
            category: .system,
            symbol: "lock.shield.fill",
            isRisky: true,
            notes: "Intended for security research devices.",
            modifications: [
                GestaltModification(key: "XYlJKKkj2hztRP1NWWnhlw",
                                    subkey: nil, value: .int(1))
            ]
        ),

        // MARK: Liquid Glass
        Tweak(
            id: "lg-lpm-enable",
            title: "Liquid Glass Low Power",
            subtitle: "Force low-power mode for Liquid Glass.",
            category: .liquidGlass,
            symbol: "drop.fill",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "SAGvsp6O6kAQ4fEfDJpC4Q",
                                    subkey: nil, value: .int(1))
            ]
        ),
        Tweak(
            id: "lg-lpm-disable",
            title: "Liquid Glass Full Fidelity",
            subtitle: "Disable Liquid Glass low-power mode.",
            category: .liquidGlass,
            symbol: "drop.halffull",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "SAGvsp6O6kAQ4fEfDJpC4Q",
                                    subkey: nil, value: .int(0))
            ]
        ),

        // MARK: iPad
        Tweak(
            id: "ipados",
            title: "iPadOS Mode",
            subtitle: "Spoof iPadOS capabilities and patch CacheData.",
            category: .ipad,
            symbol: "ipad",
            isRisky: true,
            notes: "Highly experimental. Do not enable if you use an alphanumeric passcode. Always backed up.",
            requiresCacheDataPatch: true,
            modifications: [
                GestaltModification(key: "mG0AnH/Vy1veoqoLRAIgTA",
                                    subkey: nil, value: .int(1)),
                GestaltModification(key: "UCG5MkVahJxG1YULbbd5Bg",
                                    subkey: nil, value: .int(1)),
                GestaltModification(key: "ZYqko/XM5zD3XBfN5RmaXA",
                                    subkey: nil, value: .int(1)),
                GestaltModification(key: "nVh/gwNpy7Jv1NOk00CMrw",
                                    subkey: nil, value: .int(1)),
                GestaltModification(key: "uKc7FPnEO++lVhHWHFlGbQ",
                                    subkey: nil, value: .int(1)),
            ]
        ),
        Tweak(
            id: "ipad-apps",
            title: "Allow iPad Apps",
            subtitle: "Allow iPad apps to install on iPhone.",
            category: .ipad,
            symbol: "apps.iphone",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "9MZ5AdH43csAUajl/dU+IQ",
                                    subkey: nil, value: .intArray([1, 2]))
            ]
        ),

        // MARK: Intelligence
        Tweak(
            id: "ai-gestalt",
            title: "Apple Intelligence",
            subtitle: "Advertise generative-model support in Gestalt.",
            category: .ai,
            symbol: "sparkles",
            isRisky: false,
            notes: "Gestalt flag only; the full Intelligence bundle also needs eligibility files.",
            modifications: [
                GestaltModification(key: "A62OafQ85EJAiiqKn4agtg",
                                    subkey: nil, value: .int(1))
            ]
        ),
    ]
}
