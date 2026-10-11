import Foundation

enum NetclawError: LocalizedError {
    case notConnected
    case invalidURL
    case authenticationFailed
    case serverError(Int, String)
    case decodingError(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to bettercap"
        case .invalidURL:
            return "Invalid API URL"
        case .authenticationFailed:
            return "Authentication failed. Check username/password."
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .decodingError(let detail):
            return "Failed to decode response: \(detail)"
        case .networkError(let detail):
            return "Network error: \(detail)"
        }
    }
}

enum Constants {
    static let defaultPort = 8081
    static let defaultUsername = "user"
    static let defaultPassword = "pass"
    static let eventPollInterval: TimeInterval = 1.0
    static let sessionRefreshInterval: TimeInterval = 3.0
    static let maxEventHistory = 500
}
