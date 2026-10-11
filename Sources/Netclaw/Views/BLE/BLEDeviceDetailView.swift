import SwiftUI

struct BLEDeviceDetailView: View {
    let device: BLEDevice
    @ObservedObject var viewModel: BLEViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(device.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let vendor = device.vendor, !vendor.isEmpty {
                        Text(vendor)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                LazyVGrid(columns: [
                    GridItem(.fixed(80), alignment: .trailing),
                    GridItem(.flexible(), alignment: .leading)
                ], spacing: 10) {
                    row("MAC", device.mac ?? "N/A")
                    row("RSSI", device.rssi.map { "\($0) dBm" } ?? "N/A")
                    row("Connectable", device.connectable == true ? "Yes" : "No")
                }

                if let flags = device.flags, !flags.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Flags")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        FlowLayout(spacing: 6) {
                            ForEach(flags, id: \.self) { flag in
                                Text(flag)
                                    .font(.system(size: 10, design: .monospaced))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.quaternary, in: Capsule())
                            }
                        }
                    }
                }

                Divider()

                // actions
                Button {
                    Task { await viewModel.enumerate(device, appState: appState) }
                } label: {
                    Label("Enumerate Services", systemImage: "list.bullet.rectangle")
                }

                // services
                if let services = device.services, !services.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Services (\(services.count))")
                            .font(.headline)

                        ForEach(services) { service in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(service.name ?? service.uuid ?? "Unknown")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(service.uuid ?? "")
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundStyle(.tertiary)
                                }

                                if let chars = service.characteristics {
                                    ForEach(chars) { char in
                                        HStack {
                                            Text(char.name ?? char.uuid ?? "")
                                                .font(.caption)
                                            Spacer()
                                            if let props = char.properties {
                                                Text(props.joined(separator: ", "))
                                                    .font(.system(size: 9, design: .monospaced))
                                                    .foregroundStyle(.tertiary)
                                            }
                                        }
                                        .padding(.leading, 12)
                                    }
                                }
                            }
                            .padding(10)
                            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func row(_ label: String, _ value: String) -> some View {
        Text(label)
            .font(.caption)
            .foregroundStyle(.secondary)
        Text(value)
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
    }
}
