import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable, Hashable {
    case dashboard = "Dashboard"
    case network = "Network"
    case wifi = "WiFi"
    case bluetooth = "Bluetooth"
    case sniffer = "Sniffer"
    case proxy = "Proxy"
    case caplets = "Caplets"
    case console = "Console"
    case events = "Events"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .network: return "network"
        case .wifi: return "wifi"
        case .bluetooth: return "antenna.radiowaves.left.and.right"
        case .sniffer: return "waveform.path.ecg"
        case .proxy: return "globe"
        case .caplets: return "doc.text"
        case .console: return "terminal"
        case .events: return "list.bullet.rectangle"
        }
    }

    var section: SidebarSection {
        switch self {
        case .dashboard: return .general
        case .network, .wifi, .bluetooth: return .recon
        case .sniffer, .proxy: return .attack
        case .caplets, .console, .events: return .tools
        }
    }
}

enum SidebarSection: String, CaseIterable {
    case general = "General"
    case recon = "Recon"
    case attack = "Modules"
    case tools = "Tools"
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedItem: NavigationItem? = .dashboard
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        Group {
            if appState.isConnected {
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    SidebarView(selectedItem: $selectedItem)
                        .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
                } detail: {
                    detailView
                }
                .task {
                    await refreshLoop()
                }
            } else {
                ConnectionView()
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedItem {
        case .dashboard:
            DashboardView()
        case .network:
            NetworkView()
        case .wifi:
            WiFiView()
        case .bluetooth:
            BLEView()
        case .sniffer:
            SnifferView()
        case .proxy:
            ProxyView()
        case .caplets:
            CapletsView()
        case .console:
            ConsoleView()
        case .events:
            EventsView()
        case nil:
            DashboardView()
        }
    }

    private func refreshLoop() async {
        while appState.isConnected {
            await appState.refreshSession()
            try? await Task.sleep(for: .seconds(Constants.sessionRefreshInterval))
        }
    }
}
