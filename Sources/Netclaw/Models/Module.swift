import Foundation

struct BettercapModule: Codable, Identifiable, Hashable {
    let name: String
    let running: Bool
    let description: String?
    let parameters: [String: ModuleParameter]?

    var id: String { name }

    var category: ModuleCategory {
        if name.hasPrefix("net.") || name.hasPrefix("arp.") || name.hasPrefix("dns.") || name.hasPrefix("dhcp") {
            return .network
        } else if name.hasPrefix("wifi.") {
            return .wifi
        } else if name.hasPrefix("ble.") {
            return .bluetooth
        } else if name.hasPrefix("http") {
            return .proxy
        } else if name.hasPrefix("api.") {
            return .api
        } else {
            return .other
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: BettercapModule, rhs: BettercapModule) -> Bool {
        lhs.name == rhs.name
    }
}

struct ModuleParameter: Codable, Hashable {
    let name: String?
    let description: String?
    let defaultValue: String?
    let currentValue: String?

    var value: String? {
        currentValue ?? defaultValue
    }

    enum CodingKeys: String, CodingKey {
        case name, description
        case defaultValue = "default_value"
        case currentValue = "current_value"
    }
}

enum ModuleCategory: String, CaseIterable {
    case network = "Network"
    case wifi = "WiFi"
    case bluetooth = "Bluetooth"
    case proxy = "Proxy"
    case api = "API"
    case other = "Other"

    var iconName: String {
        switch self {
        case .network: return "network"
        case .wifi: return "wifi"
        case .bluetooth: return "antenna.radiowaves.left.and.right"
        case .proxy: return "globe"
        case .api: return "server.rack"
        case .other: return "gearshape"
        }
    }
}
