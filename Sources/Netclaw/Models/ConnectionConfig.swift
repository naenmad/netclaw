import Foundation

struct ConnectionConfig: Codable {
    var host: String = "127.0.0.1"
    var port: Int = Constants.defaultPort
    var username: String = Constants.defaultUsername
    var password: String = Constants.defaultPassword
    var useHTTPS: Bool = false

    var baseURL: String {
        let scheme = useHTTPS ? "https" : "http"
        return "\(scheme)://\(host):\(port)"
    }
}
