import Foundation

struct BLEDevice: Codable, Identifiable, Hashable {
    let mac: String?
    let name: String?
    let vendor: String?
    let rssi: Int?
    let connectable: Bool?
    let firstSeen: String?
    let lastSeen: String?
    let flags: [String]?
    let services: [BLEService]?

    var id: String { mac ?? UUID().uuidString }

    var displayName: String {
        if let name, !name.isEmpty { return name }
        return mac ?? "Unknown Device"
    }

    enum CodingKeys: String, CodingKey {
        case mac, name, vendor, rssi, connectable, flags, services
        case firstSeen = "first_seen"
        case lastSeen = "last_seen"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        lhs.id == rhs.id
    }
}

struct BLEService: Codable, Identifiable, Hashable {
    let uuid: String?
    let name: String?
    let characteristics: [BLECharacteristic]?

    var id: String { uuid ?? UUID().uuidString }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BLEService, rhs: BLEService) -> Bool {
        lhs.id == rhs.id
    }
}

struct BLECharacteristic: Codable, Identifiable, Hashable {
    let uuid: String?
    let name: String?
    let properties: [String]?
    let data: String?

    var id: String { uuid ?? UUID().uuidString }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BLECharacteristic, rhs: BLECharacteristic) -> Bool {
        lhs.id == rhs.id
    }
}
