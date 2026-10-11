import SwiftUI

@MainActor
final class ConsoleViewModel: ObservableObject {
    @Published var commandInput = ""
    @Published var history: [ConsoleEntry] = []
    @Published var commandHistory: [String] = []
    @Published var historyIndex: Int = -1
    @Published var isExecuting = false

    struct ConsoleEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let command: String?
        let output: String
        let isError: Bool

        var isCommand: Bool { command != nil }
    }

    func execute(appState: AppState) async {
        let cmd = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cmd.isEmpty else { return }

        commandHistory.append(cmd)
        historyIndex = commandHistory.count
        commandInput = ""
        isExecuting = true

        history.append(ConsoleEntry(
            timestamp: Date(),
            command: cmd,
            output: "",
            isError: false
        ))

        do {
            let result = try await appState.runCommand(cmd)
            let clean = cleanOutput(result.output)
            if !clean.isEmpty {
                history.append(ConsoleEntry(
                    timestamp: Date(),
                    command: nil,
                    output: clean,
                    isError: !result.success
                ))
            }
            await appState.refreshSession()
        } catch {
            let clean = cleanOutput(error.localizedDescription)
            history.append(ConsoleEntry(
                timestamp: Date(),
                command: nil,
                output: clean,
                isError: true
            ))
        }

        isExecuting = false
    }

    private func cleanOutput(_ str: String) -> String {
        str.replacingOccurrences(of: "\\x1B\\[[0-?]*[ -/]*[@-~]", with: "", options: .regularExpression)
    }

    func navigateHistory(direction: Int) {
        let newIndex = historyIndex + direction
        guard newIndex >= 0, newIndex < commandHistory.count else {
            if newIndex >= commandHistory.count {
                historyIndex = commandHistory.count
                commandInput = ""
            }
            return
        }
        historyIndex = newIndex
        commandInput = commandHistory[newIndex]
    }

    func clear() {
        history = []
    }
}
