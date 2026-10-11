import Foundation

struct BettercapEvent: Codable, Identifiable, Equatable {
    let tag: String?
    let time: String?
    let data: EventData?

    var id: String { "\(tag ?? "")_\(time ?? UUID().uuidString)" }

    static func == (lhs: BettercapEvent, rhs: BettercapEvent) -> Bool {
        lhs.id == rhs.id
    }

    var timestamp: Date? {
        guard let time else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: time) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: time)
    }

    var category: EventCategory {
        guard let tag else { return .system }
        if tag.hasPrefix("wifi.") { return .wifi }
        if tag.hasPrefix("ble.") { return .bluetooth }
        if tag.hasPrefix("net.") || tag.hasPrefix("arp.") || tag.hasPrefix("dns.") { return .network }
        if tag.hasPrefix("http") { return .proxy }
        if tag.hasPrefix("mod.") { return .module }
        if tag.hasPrefix("sys.") || tag.hasPrefix("session.") { return .system }
        return .system
    }
}

struct EventData: Codable {
    // bettercap events have varying data structures;
    // keep it flexible by capturing raw JSON
    let rawValue: AnyCodable?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dict = try? container.decode([String: AnyCodable].self) {
            rawValue = .dictionary(dict)
        } else if let str = try? container.decode(String.self) {
            rawValue = .string(str)
        } else {
            rawValue = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let rawValue {
            try container.encode(rawValue)
        }
    }

    var description: String {
        rawValue?.stringRepresentation ?? ""
    }
}

enum AnyCodable: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case dictionary([String: AnyCodable])
    case array([AnyCodable])
    case null

    var stringRepresentation: String {
        switch self {
        case .string(let s): return s
        case .int(let i): return "\(i)"
        case .double(let d): return "\(d)"
        case .bool(let b): return "\(b)"
        case .dictionary(let dict):
            let parts = dict.map { "\($0.key): \($0.value.stringRepresentation)" }
            return parts.joined(separator: ", ")
        case .array(let arr):
            return arr.map(\.stringRepresentation).joined(separator: ", ")
        case .null: return "null"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) {
            self = .string(s)
        } else if let i = try? container.decode(Int.self) {
            self = .int(i)
        } else if let d = try? container.decode(Double.self) {
            self = .double(d)
        } else if let b = try? container.decode(Bool.self) {
            self = .bool(b)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self = .dictionary(dict)
        } else if let arr = try? container.decode([AnyCodable].self) {
            self = .array(arr)
        } else {
            self = .null
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .int(let i): try container.encode(i)
        case .double(let d): try container.encode(d)
        case .bool(let b): try container.encode(b)
        case .dictionary(let dict): try container.encode(dict)
        case .array(let arr): try container.encode(arr)
        case .null: try container.encodeNil()
        }
    }
}

enum EventCategory: String, CaseIterable {
    case network = "Network"
    case wifi = "WiFi"
    case bluetooth = "Bluetooth"
    case proxy = "Proxy"
    case module = "Module"
    case system = "System"

    var iconName: String {
        switch self {
        case .network: return "network"
        case .wifi: return "wifi"
        case .bluetooth: return "antenna.radiowaves.left.and.right"
        case .proxy: return "globe"
        case .module: return "puzzlepiece"
        case .system: return "gearshape"
        }
    }
}

struct CommandResult {
    let success: Bool
    let output: String
}
