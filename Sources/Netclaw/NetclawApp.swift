import SwiftUI

@main
struct NetclawApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 1000, minHeight: 650)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1200, height: 750)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var api: BettercapAPI?
    @Published var isConnected = false
    @Published var session: BettercapSession?
    @Published var events: [BettercapEvent] = []
    @Published var connectionConfig = ConnectionConfig()

    private var eventPoller: EventPoller?

    func connect() async throws {
        let api = BettercapAPI(config: connectionConfig)
        let session = try await api.getSession()
        self.api = api
        self.session = session
        self.isConnected = true

        // Configure default interfaces for macOS compatibility
        _ = try? await api.runCommand("set net.sniff.interface en0")
        _ = try? await api.runCommand("set wifi.interface en0")

        let poller = EventPoller(api: api)
        self.eventPoller = poller
        poller.onEvents = { [weak self] newEvents in
            Task { @MainActor in
                self?.events.insert(contentsOf: newEvents, at: 0)
                if let count = self?.events.count, count > 500 {
                    self?.events = Array(self!.events.prefix(500))
                }
            }
        }
        poller.start()
    }

    func disconnect() {
        eventPoller?.stop()
        eventPoller = nil
        api = nil
        session = nil
        isConnected = false
        events = []
    }

    func refreshSession() async {
        guard let api else { return }
        do {
            session = try await api.getSession()
        } catch {
            // silently fail on refresh; connection view will handle reconnect
        }
    }

    func toggleModule(_ name: String, on: Bool) async throws -> CommandResult {
        guard let api else {
            throw NetclawError.notConnected
        }
        let res = try await api.toggleModule(name, on: on)
        await refreshSession()
        return res
    }

    func runCommand(_ command: String) async throws -> CommandResult {
        guard let api else {
            throw NetclawError.notConnected
        }
        let res = try await api.runCommand(command)
        await refreshSession()
        return res
    }
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section("Connection") {
                TextField("Host", text: $appState.connectionConfig.host)
                TextField("Port", value: $appState.connectionConfig.port, format: .number.grouping(.never))
                TextField("Username", text: $appState.connectionConfig.username)
                SecureField("Password", text: $appState.connectionConfig.password)
                Toggle("Use HTTPS", isOn: $appState.connectionConfig.useHTTPS)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 250)
    }
}
