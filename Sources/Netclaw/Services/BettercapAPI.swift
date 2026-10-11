import Foundation

actor BettercapAPI {
    private let config: ConnectionConfig
    private let session: URLSession
    private let decoder: JSONDecoder

    init(config: ConnectionConfig) {
        self.config = config
        self.decoder = JSONDecoder()

        let urlConfig = URLSessionConfiguration.default
        urlConfig.timeoutIntervalForRequest = 10
        urlConfig.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: urlConfig)
    }

    // MARK: - Session

    func getSession() async throws -> BettercapSession {
        let data = try await request(endpoint: "/api/session", method: "GET")
        do {
            return try decoder.decode(BettercapSession.self, from: data)
        } catch {
            throw NetclawError.decodingError(error.localizedDescription)
        }
    }

    // MARK: - Commands

    func runCommand(_ command: String) async throws -> CommandResult {
        let body = ["cmd": command]
        let bodyData = try JSONEncoder().encode(body)

        let data = try await request(
            endpoint: "/api/session",
            method: "POST",
            body: bodyData
        )

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let success = (json["success"] as? Bool) ?? true
            let msg = (json["msg"] as? String) ?? ""
            return CommandResult(success: success, output: msg)
        }

        if let responseStr = String(data: data, encoding: .utf8) {
            return CommandResult(success: true, output: responseStr)
        }
        return CommandResult(success: true, output: "")
    }

    // MARK: - Events

    func getEvents(count: Int = 50) async throws -> [BettercapEvent] {
        let data = try await request(endpoint: "/api/events", method: "GET")
        do {
            return try decoder.decode([BettercapEvent].self, from: data)
        } catch {
            // bettercap sometimes wraps events differently
            if let eventsWrapper = try? decoder.decode(EventsWrapper.self, from: data) {
                return eventsWrapper.events ?? []
            }
            return []
        }
    }

    func clearEvents() async throws {
        _ = try await request(endpoint: "/api/events", method: "DELETE")
    }

    // MARK: - Convenience module commands

    func toggleModule(_ name: String, on: Bool) async throws -> CommandResult {
        let cmd = on ? "\(name) on" : "\(name) off"
        return try await runCommand(cmd)
    }

    func setParameter(_ key: String, value: String) async throws -> CommandResult {
        return try await runCommand("set \(key) \(value)")
    }

    func getParameter(_ key: String) async throws -> CommandResult {
        return try await runCommand("get \(key)")
    }

    // MARK: - Connection test

    func testConnection() async throws -> Bool {
        _ = try await getSession()
        return true
    }

    // MARK: - Private

    private func request(
        endpoint: String,
        method: String,
        body: Data? = nil
    ) async throws -> Data {
        guard let url = URL(string: config.baseURL + endpoint) else {
            throw NetclawError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Basic auth
        if !config.username.isEmpty {
            let credentials = "\(config.username):\(config.password)"
            if let credData = credentials.data(using: .utf8) {
                let base64 = credData.base64EncodedString()
                req.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body {
            req.httpBody = body
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: req)
        } catch {
            throw NetclawError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetclawError.networkError("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return data
        case 401:
            throw NetclawError.authenticationFailed
        default:
            let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown error"
            throw NetclawError.serverError(httpResponse.statusCode, message)
        }
    }
}

private struct EventsWrapper: Codable {
    let events: [BettercapEvent]?
}
