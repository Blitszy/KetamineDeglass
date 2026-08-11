import Foundation
import SwiftUI

// MARK: - Errors

enum ApplyError: LocalizedError {
    case noTweaksSelected
    case busy
    case activationFailed
    case missingPath
    case badPlist
    case missingCacheData
    case noBackup
    case writeFailed
    case writeVerificationFailed
    case restoreVerificationFailed

    var errorDescription: String? {
        switch self {
        case .noTweaksSelected: return "Select at least one tweak first."
        case .busy: return "Another operation is in progress."
        case .activationFailed: return "Could not obtain access to the MobileGestalt cache on this device."
        case .missingPath: return "The MobileGestalt path is unavailable."
        case .badPlist: return "The MobileGestalt plist could not be parsed."
        case .missingCacheData: return "CacheData is missing from the MobileGestalt plist."
        case .noBackup: return "No backup exists yet. Apply tweaks once to create one."
        case .writeFailed: return "The write to the MobileGestalt plist failed."
        case .writeVerificationFailed: return "The write did not verify. The original file was restored."
        case .restoreVerificationFailed: return "The restore did not verify. Please try again."
        }
    }
}

// MARK: - Results

struct ApplyResult: Equatable {
    let appliedCount: Int
    let warnings: [String]
    let binaryPatchApplied: Bool
    let backedUpFirstTime: Bool
}

struct RestoreResult: Equatable {
    let byteCount: Int
}

// MARK: - Store

@MainActor
final class GestaltStore: ObservableObject {

    @Published var tweaks: [Tweak] = TweakCatalog.all
    @Published private(set) var isBusy = false
    @Published private(set) var lastApply: ApplyResult?
    @Published private(set) var lastRestore: RestoreResult?
    @Published var lastError: String?

    let backup = BackupManager()

    var enabledCount: Int { tweaks.filter(\.isEnabled).count }
    var backupInfo: BackupManager.BackupInfo? { backup.info }

    // MARK: Persistence

    private let defaults = UserDefaults.standard

    private static func key(_ field: String, _ id: String) -> String {
        "tweak.\(field).\(id)"
    }

    private func loadTweakState() {
        for idx in tweaks.indices {
            let id = tweaks[idx].id
            tweaks[idx].isEnabled = defaults.bool(forKey: Self.key("enabled", id))
            tweaks[idx].selectedIndex = defaults.object(forKey: Self.key("picker", id)) as? Int ?? tweaks[idx].selectedIndex
            tweaks[idx].textValue = defaults.string(forKey: Self.key("text", id)) ?? tweaks[idx].textValue
        }
    }

    init() {
        loadTweakState()
    }

    // MARK: Toggle plumbing

    func isEnabled(_ id: String) -> Bool {
        tweaks.first { $0.id == id }?.isEnabled ?? false
    }

    func setEnabled(_ on: Bool, for id: String) {
        guard let idx = tweaks.firstIndex(where: { $0.id == id }) else { return }
        tweaks[idx].isEnabled = on
        defaults.set(on, forKey: Self.key("enabled", id))
    }

    func binding(for id: String) -> Binding<Bool> {
        Binding(
            get: { self.isEnabled(id) },
            set: { self.setEnabled($0, for: id) }
        )
    }

    func pickerBinding(for id: String) -> Binding<Int> {
        Binding(
            get: { self.tweaks.first { $0.id == id }?.selectedIndex ?? 0 },
            set: { v in
                guard let idx = self.tweaks.firstIndex(where: { $0.id == id }) else { return }
                self.tweaks[idx].selectedIndex = v
                self.defaults.set(v, forKey: Self.key("picker", id))
            }
        )
    }

    func textBinding(for id: String) -> Binding<String> {
        Binding(
            get: { self.tweaks.first { $0.id == id }?.textValue ?? "" },
            set: { v in
                guard let idx = self.tweaks.firstIndex(where: { $0.id == id }) else { return }
                self.tweaks[idx].textValue = v
                self.defaults.set(v, forKey: Self.key("text", id))
            }
        )
    }

    func resetToggles() {
        for idx in tweaks.indices { tweaks[idx].isEnabled = false }
        lastError = nil
    }

    // MARK: Engine

    /// Reads the live plist, applies every enabled tweak to an in-memory
    /// copy, writes it back in place (preserving ownership/permissions) and
    /// verifies the read-back. If verification fails the pristine backup is
    /// restored automatically so the device is never left in a broken state.
    func apply() async throws -> ApplyResult {
        guard enabledCount > 0 else { throw ApplyError.noTweaksSelected }
        guard !isBusy else { throw ApplyError.busy }
        isBusy = true
        defer { isBusy = false }

        let access = MobileGestaltAccess()
        guard (try? access.activate()) != nil else {
            throw ApplyError.activationFailed
        }
        defer { access.deactivate() }

        guard let path = access.mobileGestaltPath else { throw ApplyError.missingPath }
        let url = URL(fileURLWithPath: path)

        let current = try Data(contentsOf: url)

        // Pristine backup — created once from the untouched file.
        let hadBackup = backup.hasBackup
        try backup.ensureBackup(from: current)

        guard var plist = try PropertyListSerialization.propertyList(
            from: current, format: nil) as? [String: Any]
        else { throw ApplyError.badPlist }

        var cacheExtra = (plist["CacheExtra"] as? [String: Any]) ?? [:]
        var applied = 0
        var warnings: [String] = []

        for tweak in tweaks where tweak.isEnabled {
            do {
                var mods = tweak.modifications
                if let detail = tweak.detail {
                    switch detail {
                    case .picker(let options):
                        guard tweak.selectedIndex >= 0 && tweak.selectedIndex < options.count else {
                            warnings.append("\(tweak.title): invalid picker selection, skipped.")
                            continue
                        }
                        // Replace the picker int with the selected value.
                        mods = tweak.modifications.map { m in
                            if m.isPicker {
                                return GestaltModification(key: m.key, subkey: m.subkey,
                                                           value: .int(tweak.pickerValues[tweak.selectedIndex]))
                            }
                            return m
                        }
                        applied += 1
                    case .textField:
                        if tweak.textValue.isEmpty {
                            warnings.append("\(tweak.title): no text entered, skipped.")
                            continue
                        } else {
                            mods = tweak.modifications.map { m in
                                GestaltModification(key: m.key, subkey: m.subkey,
                                                    value: .string(tweak.textValue))
                            }
                            applied += 1
                        }
                    }
                } else {
                    applied += 1
                }
                for mod in mods {
                    if let subkey = mod.subkey {
                        var dict = (cacheExtra[mod.key] as? [String: Any]) ?? [:]
                        dict[subkey] = mod.value.plistObject
                        cacheExtra[mod.key] = dict
                    } else {
                        cacheExtra[mod.key] = mod.value.plistObject
                    }
                }
            }
        }

        plist["CacheExtra"] = cacheExtra

        // Optional binary patch (iPadOS).
        var binaryPatch = false
        if tweaks.contains(where: { $0.isEnabled && $0.requiresCacheDataPatch }) {
            guard let cacheData = plist["CacheData"] as? Data else {
                throw ApplyError.missingCacheData
            }
            plist["CacheData"] = try CacheDataPatch.apply(to: cacheData)
            binaryPatch = true
        }

        let newData = try PropertyListSerialization.data(
            fromPropertyList: plist, format: .binary, options: 0)

        do {
            try newData.write(to: url, options: []) // in place: keeps uid/gid
        } catch {
            // Never leave the device half-written.
            try? backup.restoreData().write(to: url, options: [])
            throw ApplyError.writeFailed
        }

        // Verify read-back; self-heal from the pristine backup on mismatch.
        guard let readback = try? Data(contentsOf: url), readback == newData else {
            try? backup.restoreData().write(to: url, options: [])
            throw ApplyError.writeVerificationFailed
        }

        let result = ApplyResult(
            appliedCount: applied,
            warnings: warnings,
            binaryPatchApplied: binaryPatch,
            backedUpFirstTime: !hadBackup
        )
        lastApply = result
        lastError = warnings.isEmpty ? nil : warnings.joined(separator: "\n")
        return result
    }

    /// Restores the pristine MobileGestalt plist captured on the first apply.
    func restore() async throws -> RestoreResult {
        guard backup.hasBackup else { throw ApplyError.noBackup }
        guard !isBusy else { throw ApplyError.busy }
        isBusy = true
        defer { isBusy = false }

        let access = MobileGestaltAccess()
        guard (try? access.activate()) != nil else {
            throw ApplyError.activationFailed
        }
        defer { access.deactivate() }

        guard let path = access.mobileGestaltPath else { throw ApplyError.missingPath }
        let url = URL(fileURLWithPath: path)

        let pristine = try backup.restoreData()
        do {
            try pristine.write(to: url, options: [])
        } catch {
            throw ApplyError.writeFailed
        }

        guard let readback = try? Data(contentsOf: url), readback == pristine else {
            throw ApplyError.restoreVerificationFailed
        }

        let result = RestoreResult(byteCount: pristine.count)
        lastRestore = result
        lastError = nil
        return result
    }
}
