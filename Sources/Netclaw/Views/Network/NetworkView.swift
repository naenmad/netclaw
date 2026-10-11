import SwiftUI

struct NetworkView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = NetworkViewModel()

    var body: some View {
        HSplitView {
            // host list
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
                toolbar
                Divider()
                hostTable
            }
            .frame(minWidth: 400)

            // detail panel
            if let hostId = viewModel.selectedHostId,
               let host = viewModel.allHosts(session: appState.session).first(where: { $0.id == hostId }) {
                HostDetailView(host: host)
                    .frame(minWidth: 280, idealWidth: 320)
            }
        }
        .navigationTitle("Network")
        .onAppear {
            viewModel.syncModuleStates(appState.session?.modules)
        }
        .onChange(of: appState.session?.modules) { _, modules in
            viewModel.syncModuleStates(modules)
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            // module toggles
            ModuleToggle(
                label: "Recon",
                icon: "antenna.radiowaves.left.and.right",
                isOn: viewModel.isRecon
            ) {
                Task { await viewModel.toggleNetRecon(appState) }
            }

            ModuleToggle(
                label: "Probe",
                icon: "dot.radiowaves.left.and.right",
                isOn: viewModel.isProbing
            ) {
                Task { await viewModel.toggleNetProbe(appState) }
            }

            ModuleToggle(
                label: "Sniff",
                icon: "waveform.path.ecg",
                isOn: viewModel.isSniffing
            ) {
                Task { await viewModel.toggleNetSniff(appState) }
            }

            ModuleToggle(
                label: "ARP Spoof",
                icon: "arrow.triangle.swap",
                isOn: viewModel.isArpSpoofing
            ) {
                Task { await viewModel.toggleArpSpoof(appState) }
            }

            ModuleToggle(
                label: "DNS Spoof",
                icon: "globe",
                isOn: viewModel.isDnsSpoofing
            ) {
                Task { await viewModel.toggleDnsSpoof(appState) }
            }

            Spacer()

            // search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search hosts...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .frame(width: 150)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))

            // sort
            Picker("Sort", selection: $viewModel.sortOrder) {
                ForEach(NetworkViewModel.SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .frame(width: 120)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var hostTable: some View {
        let hosts = viewModel.filteredHosts(session: appState.session)

        return Group {
            if hosts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "desktopcomputer.trianglebadge.exclamationmark")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("No hosts discovered")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !viewModel.isProbing {
                        Text("Enable net.probe to discover hosts")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Table(hosts, selection: $viewModel.selectedHostId) {
                    TableColumn("IP Address") { host in
                        Text(host.ipv4 ?? "N/A")
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(min: 100, ideal: 130)

                    TableColumn("MAC") { host in
                        Text(host.mac ?? "N/A")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .width(min: 120, ideal: 150)

                    TableColumn("Hostname") { host in
                        Text(host.displayName)
                    }
                    .width(min: 100, ideal: 150)

                    TableColumn("Vendor") { host in
                        Text(host.vendor ?? "")
                            .foregroundStyle(.secondary)
                    }
                    .width(min: 80, ideal: 120)

                    TableColumn("Last Seen") { host in
                        Text(host.lastSeenDate?.relativeString ?? "N/A")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .width(min: 60, ideal: 80)
                }
            }
        }
    }
}
