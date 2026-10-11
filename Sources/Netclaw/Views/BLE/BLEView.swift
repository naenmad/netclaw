import SwiftUI

struct BLEView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = BLEViewModel()

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
                bleToolbar
                Divider()
                deviceList
            }
            .frame(minWidth: 400)

            if let deviceId = viewModel.selectedDeviceId,
               let device = appState.session?.ble?.devices?.first(where: { $0.id == deviceId }) {
                BLEDeviceDetailView(device: device, viewModel: viewModel)
                    .frame(minWidth: 280, idealWidth: 320)
            }
        }
        .navigationTitle("Bluetooth LE")
        .onAppear {
            viewModel.syncModuleState(appState.session?.modules)
        }
        .onChange(of: appState.session?.modules) { _, modules in
            viewModel.syncModuleState(modules)
        }
    }

    private var bleToolbar: some View {
        HStack(spacing: 12) {
            ModuleToggle(
                label: "BLE Recon",
                icon: "antenna.radiowaves.left.and.right",
                isOn: viewModel.isReconRunning
            ) {
                Task { await viewModel.toggleRecon(appState) }
            }

            Spacer()

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search devices...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .frame(width: 150)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var deviceList: some View {
        let devices = viewModel.filteredDevices(appState.session?.ble?.devices)

        return Group {
            if devices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("No BLE devices found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !viewModel.isReconRunning {
                        Text("Enable ble.recon to scan for devices")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Table(devices, selection: $viewModel.selectedDeviceId) {
                    TableColumn("RSSI") { device in
                        Text("\(device.rssi ?? 0) dBm")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .width(60)

                    TableColumn("Name") { device in
                        HStack(spacing: 6) {
                            if device.connectable == true {
                                Circle()
                                    .fill(Color.netclawGreen)
                                    .frame(width: 6, height: 6)
                            }
                            Text(device.displayName)
                        }
                    }
                    .width(min: 120, ideal: 180)

                    TableColumn("MAC") { device in
                        Text(device.mac ?? "N/A")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .width(min: 120, ideal: 150)

                    TableColumn("Vendor") { device in
                        Text(device.vendor ?? "")
                            .foregroundStyle(.secondary)
                    }
                    .width(min: 80, ideal: 120)
                }
            }
        }
    }
}
