import SwiftUI

@MainActor
final class SnifferViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var capturedPackets: [SniffedPacket] = []
    @Published var filter = ""
    @Published var outputFile = ""
    @Published var verbose = false
    @Published var lastError: String?

    struct SniffedPacket: Identifiable {
        let id = UUID()
        let timestamp: Date
        let source: String
        let destination: String
        let proto: String
        let size: Int
        let info: String
    }

    func toggleSniff(_ appState: AppState) async {
        lastError = nil
        do {
            if !isRunning {
                _ = try? await appState.runCommand("set net.sniff.interface en0")
                if !filter.isEmpty {
                    _ = try? await appState.runCommand("set net.sniff.filter \(filter)")
                }
                if !outputFile.isEmpty {
                    _ = try? await appState.runCommand("set net.sniff.output \(outputFile)")
                }
                _ = try? await appState.runCommand("set net.sniff.verbose true")
                let result = try await appState.runCommand("net.sniff on")
                if !result.success { lastError = result.output }
            } else {
                let result = try await appState.runCommand("net.sniff off")
                if !result.success { lastError = result.output }
            }
            await appState.refreshSession()
            syncModuleState(appState.session?.modules)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func ingestEvents(_ events: [BettercapEvent]) {
        for event in events {
            let desc = event.data?.description ?? ""
            guard !desc.isEmpty else { continue }
            let tag = event.tag ?? ""
            if tag.hasPrefix("net.sniff") || tag.contains("packet") || (isRunning && event.category == .network) {
                let pkt = SniffedPacket(
                    timestamp: event.timestamp ?? Date(),
                    source: tag,
                    destination: "en0",
                    proto: event.category.rawValue,
                    size: desc.count,
                    info: desc
                )
                capturedPackets.insert(pkt, at: 0)
                if capturedPackets.count > 200 {
                    capturedPackets = Array(capturedPackets.prefix(200))
                }
            }
        }
    }

    func clearCapture() {
        capturedPackets = []
    }

    func syncModuleState(_ modules: [BettercapModule]?) {
        guard let modules else { return }
        if let m = modules.first(where: { $0.name == "net.sniff" }) {
            isRunning = m.running
        }
    }
}
