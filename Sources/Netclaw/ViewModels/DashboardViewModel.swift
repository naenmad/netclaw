import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isRefreshing = false

    func modulesByCategory(_ modules: [BettercapModule]?) -> [ModuleCategory: [BettercapModule]] {
        guard let modules else { return [:] }
        return Dictionary(grouping: modules, by: \.category)
    }

    func activeModuleCount(_ modules: [BettercapModule]?) -> Int {
        modules?.filter(\.running).count ?? 0
    }

    func totalModuleCount(_ modules: [BettercapModule]?) -> Int {
        modules?.count ?? 0
    }

    func hostCount(_ session: BettercapSession?) -> Int {
        session?.lan?.hosts?.count ?? 0
    }

    func apCount(_ session: BettercapSession?) -> Int {
        session?.wifi?.aps?.count ?? 0
    }

    func bleCount(_ session: BettercapSession?) -> Int {
        session?.ble?.devices?.count ?? 0
    }
}
