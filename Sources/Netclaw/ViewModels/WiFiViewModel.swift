import SwiftUI

@MainActor
final class WiFiViewModel: ObservableObject {
    @Published var selectedAPId: String?
    @Published var isReconRunning = false
    @Published var searchText = ""
    @Published var sortOrder: SortOrder = .signal
    @Published var lastError: String?
    @Published var channelFilter: Int?

    enum SortOrder: String, CaseIterable {
        case signal = "Signal"
        case name = "Name"
        case channel = "Channel"
        case clients = "Clients"
        case encryption = "Encryption"
    }

    func filteredAPs(_ aps: [WifiAP]?) -> [WifiAP] {
        guard let aps else { return [] }
        var filtered = searchText.isEmpty ? aps : aps.filter { ap in
            let s = searchText.lowercased()
            return (ap.hostname?.lowercased().contains(s) ?? false) ||
                   (ap.mac?.lowercased().contains(s) ?? false) ||
                   (ap.vendor?.lowercased().contains(s) ?? false) ||
                   (ap.encryption?.lowercased().contains(s) ?? false)
        }

        if let ch = channelFilter {
            filtered = filtered.filter { $0.channel == ch }
        }

        return filtered.sorted { a, b in
            switch sortOrder {
            case .signal:
                return (a.rssi ?? -100) > (b.rssi ?? -100)
            case .name:
                return a.displayName < b.displayName
            case .channel:
                return (a.channel ?? 0) < (b.channel ?? 0)
            case .clients:
                return a.clientCount > b.clientCount
            case .encryption:
                return (a.encryption ?? "") < (b.encryption ?? "")
            }
        }
    }

    func toggleRecon(_ appState: AppState) async {
        lastError = nil
        do {
            if !isReconRunning {
                _ = try? await appState.runCommand("set wifi.interface en0")
                let result = try await appState.runCommand("wifi.recon on")
                if !result.success {
                    lastError = result.output.isEmpty ? "Failed to start wifi.recon" : result.output
                }
            } else {
                let result = try await appState.runCommand("wifi.recon off")
                if !result.success {
                    lastError = result.output
                }
            }
            await appState.refreshSession()
            syncModuleState(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func deauthAP(_ ap: WifiAP, appState: AppState) async {
        guard let mac = ap.mac else { return }
        do {
            _ = try await appState.runCommand("wifi.deauth \(mac)")
        } catch {
            lastError = error.localizedDescription
        }
    }

    func deauthClient(_ client: WifiClient, appState: AppState) async {
        guard let mac = client.mac else { return }
        do {
            _ = try await appState.runCommand("wifi.deauth \(mac)")
        } catch {
            lastError = error.localizedDescription
        }
    }

    func setChannel(_ channel: Int, appState: AppState) async {
        do {
            _ = try await appState.runCommand("set wifi.recon.channel \(channel)")
        } catch {
            lastError = error.localizedDescription
        }
    }

    func clearChannel(_ appState: AppState) async {
        do {
            _ = try await appState.runCommand("set wifi.recon.channel \"\"")
        } catch {
            lastError = error.localizedDescription
        }
    }

    func syncModuleState(_ modules: [BettercapModule]?) {
        guard let modules else { return }
        if let m = modules.first(where: { $0.name == "wifi" || $0.name == "wifi.recon" }) {
            isReconRunning = m.running
        }
    }
}
