import Foundation

final class EventPoller: @unchecked Sendable {
    private let api: BettercapAPI
    private let interval: TimeInterval
    private var timer: Timer?
    private var lastEventId: String?
    var onEvents: (([BettercapEvent]) -> Void)?

    init(api: BettercapAPI, interval: TimeInterval = Constants.eventPollInterval) {
        self.api = api
        self.interval = interval
    }

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.poll()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() async {
        do {
            let events = try await api.getEvents()
            guard !events.isEmpty else { return }

            // filter out events we've already seen
            let newEvents: [BettercapEvent]
            if let lastId = lastEventId,
               let idx = events.firstIndex(where: { $0.id == lastId }) {
                newEvents = Array(events[..<idx])
            } else {
                newEvents = events
            }

            if let first = events.first {
                lastEventId = first.id
            }

            if !newEvents.isEmpty {
                onEvents?(newEvents)
            }
        } catch {
            // polling errors are non-fatal; the next poll will retry
        }
    }
}
