import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var isConnecting = false
    @State private var errorMessage: String?
    @State private var showAdvanced = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                // logo area
                VStack(spacing: 12) {
                    Image(systemName: "network.badge.shield.half.filled")
                        .font(.system(size: 56))
                        .foregroundStyle(.primary)
                        .symbolRenderingMode(.hierarchical)

                    Text("NETCLAW")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .tracking(4)

                    Text("Connect to a running bettercap instance")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // connection form
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Host")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("127.0.0.1", text: $appState.connectionConfig.host)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Port")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("8081", value: $appState.connectionConfig.port, format: .number.grouping(.never))
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                        }
                    }

                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Username")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("user", text: $appState.connectionConfig.username)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            SecureField("pass", text: $appState.connectionConfig.password)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    if showAdvanced {
                        Toggle("Use HTTPS", isOn: $appState.connectionConfig.useHTTPS)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }

                    Button {
                        showAdvanced.toggle()
                    } label: {
                        Text(showAdvanced ? "Hide Advanced" : "Show Advanced")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 340)

                // error
                if let errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                // connect button
                Button {
                    connect()
                } label: {
                    HStack(spacing: 8) {
                        if isConnecting {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isConnecting ? "Connecting..." : "Connect")
                            .fontWeight(.medium)
                    }
                    .frame(width: 200)
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.large)
                .disabled(isConnecting)

                // hint
                VStack(spacing: 4) {
                    Text("Make sure bettercap is running with the REST API enabled:")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text("sudo bettercap -eval \"set api.rest.username user; set api.rest.password pass; api.rest on\"")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .textSelection(.enabled)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func connect() {
        isConnecting = true
        errorMessage = nil

        Task {
            do {
                try await appState.connect()
            } catch {
                errorMessage = error.localizedDescription
            }
            isConnecting = false
        }
    }
}
