import Foundation

struct BettercapSession: Codable {
    let interface: NetworkInterface?
    let gateway: Gateway?
    let env: SessionEnv?
    let lan: LanInfo?
    let wifi: WifiInfo?
    let ble: BLEInfo?
    let modules: [BettercapModule]?
    let startedAt: String?
    let packets: PacketStats?

    enum CodingKeys: String, CodingKey {
        case interface, gateway, env, lan, wifi, ble, modules
        case startedAt = "started_at"
        case packets
    }
}

struct NetworkInterface: Codable {
    let ipv4: String?
    let ipv6: String?
    let mac: String?
    let hostname: String?
    let name: String?
    let cidrs: [String]?
}

struct Gateway: Codable {
    let ipv4: String?
    let mac: String?
    let hostname: String?
    let vendor: String?
}

struct SessionEnv: Codable {
    let data: [String: String]?
}

struct LanInfo: Codable {
    let hosts: [Host]?
}

struct WifiInfo: Codable {
    let aps: [WifiAP]?
}

struct BLEInfo: Codable {
    let devices: [BLEDevice]?
}

struct PacketStats: Codable {
    let sent: Int?
    let received: Int?
    let errors: Int?
}
