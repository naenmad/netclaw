import SwiftUI

struct ConsoleView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ConsoleViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // console output
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(viewModel.history) { entry in
                            consoleEntryView(entry)
                                .id(entry.id)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: viewModel.history.count) { _, _ in
                    if let last = viewModel.history.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .background(Color(nsColor: .textBackgroundColor).opacity(0.5))

            Divider()

            // input
            HStack(spacing: 8) {
                Text(">")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Color.netclawGreen)
                    .fontWeight(.bold)

                TextField("Enter command...", text: $viewModel.commandInput)
                    .font(.system(size: 13, design: .monospaced))
                    .textFieldStyle(.plain)
                    .focused($isInputFocused)
                    .onSubmit {
                        Task { await viewModel.execute(appState: appState) }
                    }
                    .onKeyPress(.upArrow) {
                        viewModel.navigateHistory(direction: -1)
                        return .handled
                    }
                    .onKeyPress(.downArrow) {
                        viewModel.navigateHistory(direction: 1)
                        return .handled
                    }

                if viewModel.isExecuting {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.bar)
        }
        .navigationTitle("Console")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.clear()
                } label: {
                    Image(systemName: "trash")
                }
                .help("Clear console")
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }

    @ViewBuilder
    private func consoleEntryView(_ entry: ConsoleViewModel.ConsoleEntry) -> some View {
        if entry.isCommand {
            HStack(spacing: 6) {
                Text(entry.timestamp.timestampString)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                Text(">")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.netclawGreen)
                    .fontWeight(.bold)
                Text(entry.command ?? "")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }
        } else {
            Text(entry.output)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(entry.isError ? .red : .secondary)
                .textSelection(.enabled)
                .padding(.leading, 70)
        }
    }
}
