import SwiftUI

struct WiFiView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = WiFiViewModel()

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                if let error = viewModel.lastError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(error)
                            .font(.caption)
                            .lineLimit(2)
                        Spacer()
                        Button {
                            viewModel.lastError = nil
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption2)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(Color.red.opacity(0.12))
                }
                wifiToolbar
                Divider()
                apList
            }
            .frame(minWidth: 450)

            if let apId = viewModel.selectedAPId,
               let ap = appState.session?.wifi?.aps?.first(where: { $0.id == apId }) {
                APDetailView(ap: ap, viewModel: viewModel)
                    .frame(minWidth: 280, idealWidth: 320)
            }
        }
        .navigationTitle("WiFi")
        .onAppear {
            viewModel.syncModuleState(appState.session?.modules)
        }
        .onChange(of: appState.session?.modules) { _, modules in
            viewModel.syncModuleState(modules)
        }
    }

    private var wifiToolbar: some View {
        HStack(spacing: 12) {
            ModuleToggle(
                label: "WiFi Recon",
                icon: "wifi",
                isOn: viewModel.isReconRunning
            ) {
                Task { await viewModel.toggleRecon(appState) }
            }

            Spacer()

            // channel filter
            Picker("Channel", selection: Binding(
                get: { viewModel.channelFilter ?? 0 },
                set: { viewModel.channelFilter = $0 == 0 ? nil : $0 }
            )) {
                Text("All Channels").tag(0)
                ForEach([1,2,3,4,5,6,7,8,9,10,11,12,13,36,40,44,48,149,153,157,161,165], id: \.self) { ch in
                    Text("Ch \(ch)").tag(ch)
                }
            }
            .frame(width: 120)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search APs...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .frame(width: 140)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))

            Picker("Sort", selection: $viewModel.sortOrder) {
                ForEach(WiFiViewModel.SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .frame(width: 110)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var apList: some View {
        let aps = viewModel.filteredAPs(appState.session?.wifi?.aps)

        return Group {
            if aps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("No access points found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !viewModel.isReconRunning {
                        Text("Enable wifi.recon to scan for networks")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Table(aps, selection: $viewModel.selectedAPId) {
                    TableColumn("Signal") { ap in
                        HStack(spacing: 4) {
                            Image(systemName: ap.signalStrength.iconName)
                                .font(.caption)
                                .foregroundStyle(signalColor(ap.signalStrength))
                            Text("\(ap.rssi ?? 0) dBm")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .width(min: 80, ideal: 100)

                    TableColumn("SSID") { ap in
                        Text(ap.displayName)
                            .fontWeight(ap.hostname?.isEmpty ?? true ? .regular : .medium)
                            .foregroundStyle(ap.hostname?.isEmpty ?? true ? .secondary : .primary)
                    }
                    .width(min: 100, ideal: 160)

                    TableColumn("BSSID") { ap in
                        Text(ap.mac ?? "N/A")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .width(min: 120, ideal: 140)

                    TableColumn("Ch") { ap in
                        Text(ap.channel.map(String.init) ?? "?")
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(30)

                    TableColumn("Enc") { ap in
                        Text(ap.encryption ?? "Open")
                            .font(.caption)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(encryptionColor(ap.encryption).opacity(0.15), in: Capsule())
                    }
                    .width(min: 60, ideal: 80)

                    TableColumn("Clients") { ap in
                        Text("\(ap.clientCount)")
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(50)

                    TableColumn("Flags") { ap in
                        HStack(spacing: 4) {
                            if ap.handshake == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color.netclawGreen)
                                    .help("Handshake captured")
                            }
                            if ap.pmkid == true {
                                Image(systemName: "key.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color.netclawYellow)
                                    .help("PMKID captured")
                            }
                        }
                    }
                    .width(40)
                }
            }
        }
    }

    private func signalColor(_ strength: SignalStrength) -> Color {
        switch strength {
        case .excellent: return .netclawGreen
        case .good: return .netclawGreen.opacity(0.7)
        case .fair: return .netclawYellow
        case .weak: return .netclawRed
        case .unknown: return .secondary
        }
    }

    private func encryptionColor(_ enc: String?) -> Color {
        guard let enc = enc?.uppercased() else { return .netclawRed }
        if enc.contains("WPA3") { return .netclawGreen }
        if enc.contains("WPA2") { return .netclawBlue }
        if enc.contains("WPA") { return .netclawYellow }
        if enc.contains("WEP") { return .netclawOrange }
        return .netclawRed
    }
}
