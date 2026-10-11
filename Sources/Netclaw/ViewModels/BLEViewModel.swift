import SwiftUI

@MainActor
final class BLEViewModel: ObservableObject {
    @Published var selectedDeviceId: String?
    @Published var isReconRunning = false
    @Published var searchText = ""
    @Published var lastError: String?

    func filteredDevices(_ devices: [BLEDevice]?) -> [BLEDevice] {
        guard let devices else { return [] }
        let filtered = searchText.isEmpty ? devices : devices.filter { d in
            let s = searchText.lowercased()
            return (d.name?.lowercased().contains(s) ?? false) ||
                   (d.mac?.lowercased().contains(s) ?? false) ||
                   (d.vendor?.lowercased().contains(s) ?? false)
        }
        return filtered.sorted { ($0.rssi ?? -100) > ($1.rssi ?? -100) }
    }

    func toggleRecon(_ appState: AppState) async {
        lastError = nil
        do {
            let cmd = isReconRunning ? "ble.recon off" : "ble.recon on"
            let result = try await appState.runCommand(cmd)
            if !result.success { lastError = result.output }
            await appState.refreshSession()
            syncModuleState(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func enumerate(_ device: BLEDevice, appState: AppState) async {
        guard let mac = device.mac else { return }
        do {
            _ = try await appState.runCommand("ble.enum \(mac)")
        } catch {
            lastError = error.localizedDescription
        }
    }

    func syncModuleState(_ modules: [BettercapModule]?) {
        guard let modules else { return }
        if let m = modules.first(where: { $0.name == "ble.recon" }) {
            isReconRunning = m.running
        }
    }
}
