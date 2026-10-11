import SwiftUI

struct APDetailView: View {
    let ap: WifiAP
    @ObservedObject var viewModel: WiFiViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // header
                VStack(alignment: .leading, spacing: 6) {
                    Text(ap.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let vendor = ap.vendor, !vendor.isEmpty {
                        Text(vendor)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // signal badge
                HStack(spacing: 8) {
                    Image(systemName: ap.signalStrength.iconName)
                    Text("\(ap.rssi ?? 0) dBm")
                    Text(ap.signalStrength.label)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)

                Divider()

                // AP details
                LazyVGrid(columns: [
                    GridItem(.fixed(80), alignment: .trailing),
                    GridItem(.flexible(), alignment: .leading)
                ], spacing: 10) {
                    row("BSSID", ap.mac ?? "N/A")
                    row("Channel", ap.channel.map(String.init) ?? "N/A")
                    row("Frequency", ap.frequency.map { "\($0) MHz" } ?? "N/A")
                    row("Encryption", ap.encryption ?? "Open")
                    row("Cipher", ap.cipher ?? "N/A")
                    row("Auth", ap.authentication ?? "N/A")
                    row("Handshake", ap.handshake == true ? "Captured" : "No")
                    row("PMKID", ap.pmkid == true ? "Captured" : "No")
                    row("Sent", ap.sent.map { "\($0) bytes" } ?? "0")
                    row("Received", ap.received.map { "\($0) bytes" } ?? "0")
                }

                Divider()

                // actions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Actions")
                        .font(.headline)

                    Button {
                        Task { await viewModel.deauthAP(ap, appState: appState) }
                    } label: {
                        Label("Deauth All Clients", systemImage: "xmark.circle")
                    }

                    if let ch = ap.channel {
                        Button {
                            Task { await viewModel.setChannel(ch, appState: appState) }
                        } label: {
                            Label("Lock to Channel \(ch)", systemImage: "antenna.radiowaves.left.and.right")
                        }
                    }
                }

                // clients
                if let clients = ap.clients, !clients.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clients (\(clients.count))")
                            .font(.headline)

                        ForEach(clients) { client in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(client.displayName)
                                        .font(.system(.subheadline, design: .monospaced))
                                    if let vendor = client.vendor, !vendor.isEmpty {
                                        Text(vendor)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if let rssi = client.rssi {
                                    Text("\(rssi) dBm")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                                Button {
                                    Task { await viewModel.deauthClient(client, appState: appState) }
                                } label: {
                                    Image(systemName: "xmark.circle")
                                        .font(.caption)
                                }
                                .buttonStyle(.plain)
                                .help("Deauth client")
                            }
                            .padding(.vertical, 4)
                            if client.id != clients.last?.id {
                                Divider()
                            }
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
