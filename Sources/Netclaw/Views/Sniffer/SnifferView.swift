import SwiftUI

struct SnifferView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SnifferViewModel()

    var body: some View {
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
            snifferToolbar
            Divider()
            snifferContent
        }
        .navigationTitle("Sniffer")
        .onAppear {
            viewModel.syncModuleState(appState.session?.modules)
            viewModel.ingestEvents(appState.events)
        }
        .onChange(of: appState.session?.modules) { _, modules in
            viewModel.syncModuleState(modules)
        }
        .onChange(of: appState.events.count) { _, _ in
            viewModel.ingestEvents(appState.events)
        }
    }

    private var snifferToolbar: some View {
        HStack(spacing: 12) {
            ModuleToggle(
                label: "net.sniff",
                icon: "waveform.path.ecg",
                isOn: viewModel.isRunning
            ) {
                Task { await viewModel.toggleSniff(appState) }
            }

            Divider()
                .frame(height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text("BPF Filter")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                TextField("e.g. tcp port 80", text: $viewModel.filter)
                    .font(.system(size: 11, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Output File")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                TextField("/tmp/capture.pcap", text: $viewModel.outputFile)
                    .font(.system(size: 11, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
            }

            Toggle("Verbose", isOn: $viewModel.verbose)
                .toggleStyle(.switch)
                .controlSize(.small)

            Spacer()

            Button {
                viewModel.clearCapture()
            } label: {
                Image(systemName: "trash")
            }
            .help("Clear capture")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var snifferContent: some View {
        Group {
            if viewModel.capturedPackets.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)

                    if viewModel.isRunning {
                        Text("Capturing packets...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Packet data appears in the Events tab")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Sniffer is not running")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Configure filters above, then enable net.sniff")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Table(viewModel.capturedPackets) {
                    TableColumn("Time") { pkt in
                        Text(pkt.timestamp.timestampString)
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .width(80)
                    TableColumn("Source") { pkt in
                        Text(pkt.source)
                            .font(.system(size: 11, design: .monospaced))
                    }
                    TableColumn("Destination") { pkt in
                        Text(pkt.destination)
                            .font(.system(size: 11, design: .monospaced))
                    }
                    TableColumn("Proto") { pkt in
                        Text(pkt.proto)
                            .font(.caption)
                    }
                    .width(60)
                    TableColumn("Size") { pkt in
                        Text("\(pkt.size)")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .width(50)
                    TableColumn("Info") { pkt in
                        Text(pkt.info)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
