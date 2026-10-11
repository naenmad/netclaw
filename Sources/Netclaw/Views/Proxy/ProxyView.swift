import SwiftUI

struct ProxyView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProxyViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // HTTP Proxy
                proxyCard(
                    title: "HTTP Proxy",
                    icon: "globe",
                    description: "Intercept and modify HTTP traffic",
                    isRunning: viewModel.isHttpProxyRunning,
                    toggle: { Task { await viewModel.toggleHttpProxy(appState) } },
                    settings: {
                        HStack {
                            Text("Port")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("8080", text: $viewModel.httpProxyPort)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Button("Apply") {
                                Task { await viewModel.applyHttpProxySettings(appState) }
                            }
                            .controlSize(.small)
                        }
                    }
                )

                // HTTPS Proxy
                proxyCard(
                    title: "HTTPS Proxy",
                    icon: "lock.shield",
                    description: "Intercept HTTPS traffic (requires SSL certificate)",
                    isRunning: viewModel.isHttpsProxyRunning,
                    toggle: { Task { await viewModel.toggleHttpsProxy(appState) } },
                    settings: { EmptyView() }
                )

                // HTTP Server
                proxyCard(
                    title: "HTTP Server",
                    icon: "server.rack",
                    description: "Serve files over HTTP",
                    isRunning: viewModel.isHttpServerRunning,
                    toggle: { Task { await viewModel.toggleHttpServer(appState) } },
                    settings: {
                        HStack {
                            Text("Path")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("/tmp", text: $viewModel.httpServerPath)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)
                        }
                    }
                )

                // error display
                if let error = viewModel.lastError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(error)
                            .font(.caption)
                    }
                    .padding(10)
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(20)
        }
        .navigationTitle("Proxy")
        .onAppear {
            viewModel.syncModuleStates(appState.session?.modules)
        }
        .onChange(of: appState.session?.modules) { _, modules in
            viewModel.syncModuleStates(modules)
        }
    }

    private func proxyCard<Settings: View>(
        title: String,
        icon: String,
        description: String,
        isRunning: Bool,
        toggle: @escaping () -> Void,
        @ViewBuilder settings: () -> Settings
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isRunning ? Color.netclawGreen : Color.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    toggle()
                } label: {
                    Text(isRunning ? "Stop" : "Start")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(isRunning ? Color.red : Color.netclawGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            (isRunning ? Color.red : Color.netclawGreen).opacity(0.1),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }

            settings()
        }
        .padding(16)
        .cardStyle()
    }
}
