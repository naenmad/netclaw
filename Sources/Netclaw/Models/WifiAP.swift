import Foundation

struct WifiAP: Codable, Identifiable, Hashable {
    let hostname: String?
    let mac: String?
    let vendor: String?
    let channel: Int?
    let frequency: Int?
    let rssi: Int?
    let encryption: String?
    let cipher: String?
    let authentication: String?
    let wps: [String: String]?
    let handshake: Bool?
    let pmkid: Bool?
    let halfHandshake: Bool?
    let firstSeen: String?
    let lastSeen: String?
    let clients: [WifiClient]?
    let sent: Int?
    let received: Int?

    var id: String { mac ?? UUID().uuidString }

    var displayName: String {
        if let hostname, !hostname.isEmpty { return hostname }
        return mac ?? "Hidden Network"
    }

    var signalStrength: SignalStrength {
        guard let rssi else { return .unknown }
        if rssi >= -50 { return .excellent }
        if rssi >= -60 { return .good }
        if rssi >= -70 { return .fair }
        return .weak
    }

    var clientCount: Int { clients?.count ?? 0 }

    enum CodingKeys: String, CodingKey {
        case hostname, mac, vendor, channel, frequency, rssi
        case encryption, cipher, authentication, wps
        case handshake, pmkid
        case halfHandshake = "half_handshake"
        case firstSeen = "first_seen"
        case lastSeen = "last_seen"
        case clients, sent, received
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: WifiAP, rhs: WifiAP) -> Bool {
        lhs.id == rhs.id
    }
}

struct WifiClient: Codable, Identifiable, Hashable {
    let mac: String?
    let hostname: String?
    let vendor: String?
    let rssi: Int?
    let frequency: Int?
    let firstSeen: String?
    let lastSeen: String?
    let sent: Int?
    let received: Int?

    var id: String { mac ?? UUID().uuidString }

    var displayName: String {
        hostname ?? mac ?? "Unknown Client"
    }

    enum CodingKeys: String, CodingKey {
        case mac, hostname, vendor, rssi, frequency, sent, received
        case firstSeen = "first_seen"
        case lastSeen = "last_seen"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: WifiClient, rhs: WifiClient) -> Bool {
        lhs.id == rhs.id
    }
}

enum SignalStrength {
    case excellent, good, fair, weak, unknown

    var label: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .weak: return "Weak"
        case .unknown: return "N/A"
        }
    }

    var iconName: String {
        switch self {
        case .excellent: return "wifi"
        case .good: return "wifi"
        case .fair: return "wifi.exclamationmark"
        case .weak: return "wifi.slash"
        case .unknown: return "wifi.slash"
        }
    }
}
