import SwiftUI

@MainActor
final class ProxyViewModel: ObservableObject {
    @Published var isHttpProxyRunning = false
    @Published var isHttpsProxyRunning = false
    @Published var isHttpServerRunning = false
    @Published var httpProxyPort = "8080"
    @Published var httpsProxyPort = "8083"
    @Published var httpServerPort = "80"
    @Published var httpServerPath = "/tmp"
    @Published var lastError: String?

    func toggleHttpProxy(_ appState: AppState) async {
        lastError = nil
        do {
            let cmd = isHttpProxyRunning ? "http.proxy off" : "http.proxy on"
            let result = try await appState.runCommand(cmd)
            if !result.success { lastError = result.output }
            await appState.refreshSession()
            syncModuleStates(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggleHttpsProxy(_ appState: AppState) async {
        lastError = nil
        do {
            let cmd = isHttpsProxyRunning ? "https.proxy off" : "https.proxy on"
            let result = try await appState.runCommand(cmd)
            if !result.success { lastError = result.output }
            await appState.refreshSession()
            syncModuleStates(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggleHttpServer(_ appState: AppState) async {
        lastError = nil
        do {
            let cmd = isHttpServerRunning ? "http.server off" : "http.server on"
            let result = try await appState.runCommand(cmd)
            if !result.success { lastError = result.output }
            await appState.refreshSession()
            syncModuleStates(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func applyHttpProxySettings(_ appState: AppState) async {
        do {
            _ = try await appState.runCommand("set http.proxy.port \(httpProxyPort)")
        } catch {
            lastError = error.localizedDescription
        }
    }

    func syncModuleStates(_ modules: [BettercapModule]?) {
        guard let modules else { return }
        for m in modules {
            switch m.name {
            case "http.proxy": isHttpProxyRunning = m.running
            case "https.proxy": isHttpsProxyRunning = m.running
            case "http.server": isHttpServerRunning = m.running
            default: break
            }
        }
    }
}
