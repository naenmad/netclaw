import SwiftUI

struct CapletsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = CapletsViewModel()
    @State private var showEditor = false

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                capletsToolbar
                Divider()
                capletsList
            }
            .frame(minWidth: 300)

            if showEditor {
                CapletEditorView(viewModel: viewModel)
                    .frame(minWidth: 400)
            }
        }
        .navigationTitle("Caplets")
        .task {
            await viewModel.loadCaplets(appState)
        }
    }

    private var capletsToolbar: some View {
        HStack(spacing: 12) {
            Button {
                Task { await viewModel.loadCaplets(appState) }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }

            Button {
                showEditor.toggle()
            } label: {
                Label(showEditor ? "Hide Editor" : "Show Editor", systemImage: "doc.text")
            }

            Spacer()

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search caplets...", text: $viewModel.searchText)
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

    private var capletsList: some View {
        Group {
            if viewModel.filteredCaplets.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("No caplets found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Run 'caplets.update' in the console to download caplets")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.filteredCaplets, selection: $viewModel.selectedCaplet) { caplet in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(caplet.name)
                                .font(.system(.body, design: .monospaced))
                            if !caplet.description.isEmpty {
                                Text(caplet.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Button {
                            Task { await viewModel.runCaplet(caplet, appState: appState) }
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.netclawGreen)
                        .help("Run caplet")
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct CapletEditorView: View {
    @ObservedObject var viewModel: CapletsViewModel
    @EnvironmentObject var appState: AppState
    @State private var editorText = "# Enter caplet commands here\n# Lines starting with # are comments\n\n"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Caplet Editor")
                    .font(.headline)
                Spacer()
                Button {
                    Task {
                        await viewModel.runInlineCaplet(content: editorText, appState: appState)
                    }
                } label: {
                    Label("Run", systemImage: "play.fill")
                }
                .controlSize(.small)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            TextEditor(text: $editorText)
                .font(.system(size: 12, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
        }
    }
}
