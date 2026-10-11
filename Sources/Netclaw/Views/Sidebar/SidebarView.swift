import SwiftUI

struct SidebarView: View {
    @Binding var selectedItem: NavigationItem?
    @EnvironmentObject var appState: AppState

    var body: some View {
        List(selection: $selectedItem) {
            ForEach(SidebarSection.allCases, id: \.self) { section in
                Section(section.rawValue) {
                    ForEach(NavigationItem.allCases.filter { $0.section == section }) { item in
                        NavigationLink(value: item) {
                            Label {
                                Text(item.rawValue)
                            } icon: {
                                Image(systemName: item.icon)
                                    .foregroundStyle(iconColor(for: item))
                            }
                            .badge(badgeCount(for: item))
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            selectedItem = item
                        })
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            connectionStatusBar
        }
    }

    private var connectionStatusBar: some View {
        VStack(spacing: 6) {
            Divider()
            HStack(spacing: 8) {
                Circle()
                    .fill(appState.isConnected ? Color.netclawGreen : Color.netclawRed)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 1) {
                    Text(appState.isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(appState.connectionConfig.host)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    appState.disconnect()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Disconnect")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(.bar)
    }

    private func iconColor(for item: NavigationItem) -> Color {
        switch item {
        case .dashboard: return .netclawBlue
        case .network: return .netclawGreen
        case .wifi: return .netclawPurple
        case .bluetooth: return .netclawCyan
        case .sniffer: return .netclawOrange
        case .proxy: return .netclawYellow
        case .caplets: return .netclawRed
        case .console: return .primary
        case .events: return .secondary
        }
    }

    private func badgeCount(for item: NavigationItem) -> Int {
        switch item {
        case .network: return appState.session?.lan?.hosts?.count ?? 0
        case .wifi: return appState.session?.wifi?.aps?.count ?? 0
        case .bluetooth: return appState.session?.ble?.devices?.count ?? 0
        case .events: return min(appState.events.count, 99)
        default: return 0
        }
    }
}
