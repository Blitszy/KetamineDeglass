import Foundation

/// Faithful port of Nugget's `MobileGestaltCacheDataTweak`
/// (slice_start 1616, slice_length 200) that flips a single nibble of the
/// `CacheData` blob to enable iPadOS. Reversible: the whole plist is backed
/// up before any write, and the patch is only ever applied to an in-memory
/// copy that is discarded on error.
enum CacheDataPatch {

    enum PatchError: LocalizedError {
        case tooShort
        case patternNotFound
        case outOfRange(side: String)
        case invalidValue(side: String, value: Character)
        case badNeighbor(side: String)

        var errorDescription: String? {
            switch self {
            case .tooShort:
                return "CacheData is too short for the iPadOS patch."
            case .patternNotFound:
                return "The iPadOS pattern was not found in CacheData. Your device or iOS version may be unsupported."
            case .outOfRange(let side):
                return "The \(side) offset is out of range for CacheData."
            case .invalidValue(let side, let value):
                return "The value at the \(side) offset (\(value)) is not 1 or 3."
            case .badNeighbor(let side):
                return "The neighbours of the \(side) offset are not zero."
            }
        }
    }

    static let sliceStart = 1616
    static let sliceLength = 200

    static func apply(to data: Data) throws -> Data {
        let hex = data.map { String(format: "%02x", $0) }.joined()
        guard hex.count > sliceStart else { throw PatchError.tooShort }

        let windowStart = hex.index(hex.startIndex, offsetBy: sliceStart)
        let windowEnd = hex.index(windowStart, offsetBy: sliceLength)
        let window = String(hex[windowStart..<windowEnd])

        // Nugget regex: 0+(?:5555)*([0-9a-f]{4})
        let regex = try NSRegularExpression(pattern: "0+(?:5555)*([0-9a-f]{4})")
        let nsWindow = window as NSString
        let range = NSRange(location: 0, length: nsWindow.length)

        var offset: Int?
        var value = ""
        regex.enumerateMatches(in: window, options: [], range: range) { match, _, _ in
            guard let match else { return }
            let cap = match.range(at: 1)
            guard cap.location != NSNotFound else { return }
            let captured = nsWindow.substring(with: cap)
            let nonZero = captured.filter { $0 != "0" }.count
            if nonZero >= 3 {
                offset = sliceStart + cap.location
                value = captured
            }
        }
        _ = value
        guard let offset else { throw PatchError.patternNotFound }

        // Extremes (hex-character offsets, matching Nugget)
        let roffset = offset + 13
        let loffset = offset - 67
        let chars = Array(hex)
        guard roffset < chars.count - 1, roffset - 1 >= 0 else {
            throw PatchError.outOfRange(side: "right")
        }
        guard loffset > 0, loffset + 1 < chars.count else {
            throw PatchError.outOfRange(side: "left")
        }

        for side in [(loffset, "left"), (roffset, "right")] {
            let idx = side.0
            let name = side.1
            let ch = chars[idx]
            guard ch == "1" || ch == "3" else {
                throw PatchError.invalidValue(side: name, value: ch)
            }
            guard chars[idx - 1] == "0", chars[idx + 1] == "0" else {
                throw PatchError.badNeighbor(side: name)
            }
        }

        // Flip the left offset nibble to 3 (the actual enable bit).
        var mutable = chars
        mutable[loffset] = "3"

        // Rebuild bytes from the hex string.
        let rebuilt = String(mutable)
        var bytes = Data()
        bytes.reserveCapacity(rebuilt.count / 2)
        var i = rebuilt.startIndex
        while i < rebuilt.endIndex {
            let next = rebuilt.index(after: i)
            if let byte = UInt8(rebuilt[i...next], radix: 16) {
                bytes.append(byte)
            }
            i = rebuilt.index(after: next)
        }
        guard bytes.count == data.count else { throw PatchError.patternNotFound }
        return bytes
    }
}
