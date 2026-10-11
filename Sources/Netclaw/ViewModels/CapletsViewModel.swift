import SwiftUI

@MainActor
final class CapletsViewModel: ObservableObject {
    @Published var caplets: [CapletFile] = []
    @Published var selectedCaplet: CapletFile?
    @Published var editorContent = ""
    @Published var searchText = ""
    @Published var lastError: String?

    struct CapletFile: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let path: String
        let description: String

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: CapletFile, rhs: CapletFile) -> Bool {
            lhs.id == rhs.id
        }
    }

    func loadCaplets(_ appState: AppState) async {
        do {
            let result = try await appState.runCommand("caplets.show")
            parseCapletsList(result.output)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func runCaplet(_ caplet: CapletFile, appState: AppState) async {
        do {
            _ = try await appState.runCommand("caplet \(caplet.name)")
        } catch {
            lastError = error.localizedDescription
        }
    }

    func runInlineCaplet(content: String, appState: AppState) async {
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }

        for line in lines {
            do {
                _ = try await appState.runCommand(line)
            } catch {
                lastError = "Failed at: \(line) - \(error.localizedDescription)"
                break
            }
        }
    }

    var filteredCaplets: [CapletFile] {
        guard !searchText.isEmpty else { return caplets }
        let s = searchText.lowercased()
        return caplets.filter {
            $0.name.lowercased().contains(s) ||
            $0.description.lowercased().contains(s)
        }
    }

    private func parseCapletsList(_ output: String) {
        // parse bettercap's caplets.show output into structured data
        let lines = output.components(separatedBy: .newlines)
        var parsed: [CapletFile] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("+"), !trimmed.hasPrefix("|") else { continue }
            // simple heuristic: lines with .cap are caplet names
            if trimmed.hasSuffix(".cap") || trimmed.contains("/") {
                parsed.append(CapletFile(
                    name: trimmed,
                    path: trimmed,
                    description: ""
                ))
            }
        }
        caplets = parsed
    }
}
