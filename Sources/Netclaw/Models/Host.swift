import Foundation

struct Host: Codable, Identifiable, Hashable {
    let ipv4: String?
    let ipv6: String?
    let mac: String?
    let hostname: String?
    let vendor: String?
    let alias: String?
    let firstSeen: String?
    let lastSeen: String?
    let meta: HostMeta?

    var id: String { mac ?? ipv4 ?? UUID().uuidString }

    var displayName: String {
        if let alias, !alias.isEmpty { return alias }
        if let hostname, !hostname.isEmpty { return hostname }
        return ipv4 ?? mac ?? "Unknown"
    }

    var lastSeenDate: Date? {
        guard let lastSeen else { return nil }
        return ISO8601DateFormatter().date(from: lastSeen)
    }

    var firstSeenDate: Date? {
        guard let firstSeen else { return nil }
        return ISO8601DateFormatter().date(from: firstSeen)
    }

    enum CodingKeys: String, CodingKey {
        case ipv4, ipv6, mac, hostname, vendor, alias, meta
        case firstSeen = "first_seen"
        case lastSeen = "last_seen"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Host, rhs: Host) -> Bool {
        lhs.id == rhs.id
    }
}

struct HostMeta: Codable {
    let values: [String: MetaValue]?
}

struct MetaValue: Codable {
    let value: String?
    let time: String?
}
