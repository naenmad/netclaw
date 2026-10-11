import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // interface info
                if let iface = appState.session?.interface {
                    interfaceCard(iface)
                }

                // stats grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 14) {
                    StatCard(
                        title: "Hosts",
                        value: "\(viewModel.hostCount(appState.session))",
                        icon: "desktopcomputer",
                        color: .netclawGreen
                    )
                    StatCard(
                        title: "WiFi APs",
                        value: "\(viewModel.apCount(appState.session))",
                        icon: "wifi",
                        color: .netclawPurple
                    )
                    StatCard(
                        title: "BLE Devices",
                        value: "\(viewModel.bleCount(appState.session))",
                        icon: "antenna.radiowaves.left.and.right",
                        color: .netclawCyan
                    )
                    StatCard(
                        title: "Modules",
                        value: "\(viewModel.activeModuleCount(appState.session?.modules)) / \(viewModel.totalModuleCount(appState.session?.modules))",
                        icon: "puzzlepiece",
                        color: .netclawOrange
                    )
                }

                // modules overview
                if let modules = appState.session?.modules {
                    modulesSection(modules)
                }

                // recent events
                recentEventsSection
            }
            .padding(20)
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    Task { await appState.refreshSession() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")
            }
        }
    }

    private func interfaceCard(_ iface: NetworkInterface) -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Label {
                    Text("Interface")
                        .font(.headline)
                } icon: {
                    Image(systemName: "network")
                }

                HStack(spacing: 16) {
                    infoItem("Name", value: iface.name ?? "N/A")
                    infoItem("IPv4", value: iface.ipv4 ?? "N/A")
                    infoItem("IPv6", value: iface.ipv6 ?? "N/A")
                    infoItem("MAC", value: iface.mac ?? "N/A")
                }
            }

            Spacer()

            if let gw = appState.session?.gateway {
                VStack(alignment: .leading, spacing: 6) {
                    Label {
                        Text("Gateway")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "arrow.triangle.branch")
                    }

                    HStack(spacing: 16) {
                        infoItem("IPv4", value: gw.ipv4 ?? "N/A")
                        infoItem("MAC", value: gw.mac ?? "N/A")
                        if let vendor = gw.vendor, !vendor.isEmpty {
                            infoItem("Vendor", value: vendor)
                        }
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func infoItem(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private func modulesSection(_ modules: [BettercapModule]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Modules")
                .font(.headline)

            let grouped = viewModel.modulesByCategory(modules)
            ForEach(ModuleCategory.allCases, id: \.self) { category in
                if let mods = grouped[category], !mods.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(category.rawValue, systemImage: category.iconName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        FlowLayout(spacing: 8) {
                            ForEach(mods) { mod in
                                ModulePill(module: mod)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    private var recentEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Events")
                    .font(.headline)
                Spacer()
                Text("\(appState.events.count) events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if appState.events.isEmpty {
                Text("No events yet")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 2) {
                    ForEach(appState.events.prefix(10)) { event in
                        EventRow(event: event)
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .cardStyle()
    }
}

struct ModulePill: View {
    @EnvironmentObject var appState: AppState
    let module: BettercapModule
    @State private var isToggling = false

    var body: some View {
        Button {
            Task {
                isToggling = true
                _ = try? await appState.toggleModule(module.name, on: !module.running)
                isToggling = false
            }
        } label: {
            HStack(spacing: 5) {
                if isToggling {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Circle()
                        .fill(module.running ? Color.netclawGreen : Color.netclawRed.opacity(0.5))
                        .frame(width: 6, height: 6)
                }
                Text(module.name)
                    .font(.system(size: 11, design: .monospaced))
                if module.running {
                    Text("ON")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.netclawGreen)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                module.running
                    ? Color.netclawGreen.opacity(0.12)
                    : Color.secondary.opacity(0.06),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        module.running
                            ? Color.netclawGreen.opacity(0.4)
                            : Color.secondary.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .help("Click to \(module.running ? "stop" : "start") \(module.name)")
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, point) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxHeight = max(maxHeight, y + rowHeight)
        }

        return (CGSize(width: maxWidth, height: maxHeight), positions)
    }
}
