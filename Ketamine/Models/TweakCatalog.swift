import Foundation

/// All tweaks in this app rely exclusively on the MobileGestalt cache —
/// the same keys Nugget writes. Keys are written under `CacheExtra`.
enum TweakCatalog {

    static let all: [Tweak] = [
        // MARK: Display
        Tweak(
            id: "dynamic-island",
            title: "Dynamic Island",
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
            category: .device,
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
            id: "device-subtype",
            title: "Device Artwork Subtype",
            subtitle: "Report a different device model for artwork/UI behavior.",
            category: .device,
            symbol: "iphone.gen3",
            isRisky: true,
            notes: "Changes the reported device. Some subtypes disable the Dynamic Island; some devices only support certain values. 'Original' keeps the device's current value. 'None' disables the Dynamic Island.",
            detail: .picker(options: [
                "Original",
                "None (Disable Dynamic Island)",
                "iPhone 14 Pro",
                "iPhone 14 Pro Max",
                "iPhone 15 Pro Max",
                "iPhone 16 Pro",
                "iPhone 16 Pro Max",
                "iPhone Air",
            ]),
            pickerValues: [.keepCurrent, .int(0), .int(2436), .int(2796), .int(2976), .int(2622), .int(2868), .int(2736)],
            modifications: [
                GestaltModification(key: "oPeik/9e8lQWMszEjbPzng",
                                    subkey: "ArtworkDeviceSubType",
                                    value: .keepCurrent, isPicker: true)
            ]
        ),
        Tweak(
            id: "product-type",
            title: "Device Spoof (ProductType)",
            subtitle: "Spoof the reported model for Apple Intelligence eligibility.",
            category: .device,
            symbol: "cpu",
            isRisky: true,
            notes: "Spoof to an AI-capable model, back, then to your final model — the AI icon appears in Settings. Don't re-enter Apple Intelligence & Siri settings after un-spoofing. May break Face ID if you keep the spoof.",
            detail: .picker(options: [
                "Default (real model)",
                "iPhone 15 Pro",
                "iPhone 15 Pro Max",
                "iPhone 16",
                "iPhone 16 Plus",
                "iPhone 16 Pro",
                "iPhone 16 Pro Max",
                "iPhone 17",
                "iPhone 17 Pro",
                "iPhone 17 Pro Max",
                "iPhone Air",
            ]),
            pickerValues: [.remove, .string("iPhone16,1"), .string("iPhone16,2"), .string("iPhone17,3"), .string("iPhone17,4"), .string("iPhone17,1"), .string("iPhone17,2"), .string("iPhone18,3"), .string("iPhone18,1"), .string("iPhone18,2"), .string("iPhone18,4")],
            modifications: [
                GestaltModification(key: "h9jDsbgj7xIVeIQ8S3/X3Q",
                                    subkey: nil,
                                    value: .remove, isPicker: true)
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
        Tweak(
            id: "pwm",
            title: "Pulse Width Modulation",
            subtitle: "Advertise PWM display support.",
            category: .display,
            symbol: "waveform",
            isRisky: false,
            notes: nil,
            modifications: [
                GestaltModification(key: "6IejgN+1Fmu5/QrZFOIeNw",
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
            id: "internal-features",
            title: "Internal Features",
            subtitle: "Expose internal settings and build flags via CacheData.",
            category: .system,
            symbol: "ant",
            isRisky: true,
            notes: "Writes the internal-build, internal-settings-bundle and internal-install flags directly into CacheData (mond-style offset writes).",
            modifications: [
                GestaltModification(key: "EqrsVvjcYDdxHBiQmGhAWw",
                                    subkey: nil, value: .int(1),
                                    cacheDataKey: "EqrsVvjcYDdxHBiQmGhAWw",
                                    cacheDataDisabledValue: 0),
                GestaltModification(key: "Oji6HRoPi7rH7HPdWVakuw",
                                    subkey: nil, value: .int(1),
                                    cacheDataKey: "Oji6HRoPi7rH7HPdWVakuw",
                                    cacheDataDisabledValue: 0),
                GestaltModification(key: "LBJfwOEzExRxzlAnSuI7eg",
                                    subkey: nil, value: .int(1),
                                    cacheDataKey: "LBJfwOEzExRxzlAnSuI7eg",
                                    cacheDataDisabledValue: 0),
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
            notes: "Use with Device Spoof: spoof to an AI-capable model, spoof back, then to your final model. Keep it plugged in with Settings open while it evaluates. On iOS 27 you can also force eligibility directly via the Eligibility tab.",
            modifications: [
                GestaltModification(key: "A62OafQ85EJAiiqKn4agtg",
                                    subkey: nil, value: .int(1))
            ]
        ),
    ]
}
