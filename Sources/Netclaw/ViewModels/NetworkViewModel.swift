import SwiftUI

@MainActor
final class NetworkViewModel: ObservableObject {
    @Published var selectedHostId: String?
    @Published var isRecon = false
    @Published var isProbing = false
    @Published var isSniffing = false
    @Published var isArpSpoofing = false
    @Published var isDnsSpoofing = false
    @Published var searchText = ""
    @Published var sortOrder: SortOrder = .ip
    @Published var lastError: String?

    enum SortOrder: String, CaseIterable {
        case ip = "IP Address"
        case hostname = "Hostname"
        case lastSeen = "Last Seen"
        case vendor = "Vendor"
    }

    func allHosts(session: BettercapSession?) -> [Host] {
        var list = session?.lan?.hosts ?? []

        // If gateway exists and is not already in list, add it
        if let gw = session?.gateway, let gwIp = gw.ipv4, !gwIp.isEmpty {
            if !list.contains(where: { $0.ipv4 == gwIp }) {
                let gwHost = Host(
                    ipv4: gw.ipv4,
                    ipv6: nil,
                    mac: gw.mac,
                    hostname: gw.hostname ?? "Gateway",
                    vendor: gw.vendor,
                    alias: "Gateway",
                    firstSeen: nil,
                    lastSeen: nil,
                    meta: nil
                )
                list.insert(gwHost, at: 0)
            }
        }
        return list
    }

    func filteredHosts(session: BettercapSession?) -> [Host] {
        let hosts = allHosts(session: session)
        let filtered = searchText.isEmpty ? hosts : hosts.filter { host in
            let searchLower = searchText.lowercased()
            return (host.ipv4?.lowercased().contains(searchLower) ?? false) ||
                   (host.hostname?.lowercased().contains(searchLower) ?? false) ||
                   (host.mac?.lowercased().contains(searchLower) ?? false) ||
                   (host.vendor?.lowercased().contains(searchLower) ?? false) ||
                   (host.alias?.lowercased().contains(searchLower) ?? false)
        }

        return filtered.sorted { a, b in
            switch sortOrder {
            case .ip:
                return (a.ipv4 ?? "") < (b.ipv4 ?? "")
            case .hostname:
                return (a.displayName) < (b.displayName)
            case .lastSeen:
                return (a.lastSeen ?? "") > (b.lastSeen ?? "")
            case .vendor:
                return (a.vendor ?? "") < (b.vendor ?? "")
            }
        }
    }

    func toggleNetRecon(_ appState: AppState) async {
        lastError = nil
        do {
            let cmd = isRecon ? "net.recon off" : "net.recon on"
            let result = try await appState.runCommand(cmd)
            if !result.success { lastError = result.output }
            await appState.refreshSession()
            syncModuleStates(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggleNetProbe(_ appState: AppState) async {
        lastError = nil
        do {
            if !isProbing {
                // Ensure net.recon is on so discovered hosts are recorded
                if !isRecon {
                    _ = try? await appState.runCommand("net.recon on")
                }
                let result = try await appState.runCommand("net.probe on")
                if !result.success { lastError = result.output }
            } else {
                let result = try await appState.runCommand("net.probe off")
                if !result.success { lastError = result.output }
            }
            await appState.refreshSession()
            syncModuleStates(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggleNetSniff(_ appState: AppState) async {
        lastError = nil
        do {
            if !isSniffing {
                _ = try? await appState.runCommand("set net.sniff.interface en0")
                let result = try await appState.runCommand("net.sniff on")
                if !result.success { lastError = result.output }
            } else {
                let result = try await appState.runCommand("net.sniff off")
                if !result.success { lastError = result.output }
            }
            await appState.refreshSession()
            syncModuleStates(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggleArpSpoof(_ appState: AppState) async {
        lastError = nil
        do {
            let cmd = isArpSpoofing ? "arp.spoof off" : "arp.spoof on"
            let result = try await appState.runCommand(cmd)
            if !result.success { lastError = result.output }
            await appState.refreshSession()
            syncModuleStates(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggleDnsSpoof(_ appState: AppState) async {
        lastError = nil
        do {
            let cmd = isDnsSpoofing ? "dns.spoof off" : "dns.spoof on"
            let result = try await appState.runCommand(cmd)
            if !result.success { lastError = result.output }
            await appState.refreshSession()
            syncModuleStates(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func syncModuleStates(_ modules: [BettercapModule]?) {
        guard let modules else { return }
        for m in modules {
            switch m.name {
            case "net.recon": isRecon = m.running
            case "net.probe": isProbing = m.running
            case "net.sniff": isSniffing = m.running
            case "arp.spoof": isArpSpoofing = m.running
            case "dns.spoof": isDnsSpoofing = m.running
            default: break
            }
        }
    }
}
