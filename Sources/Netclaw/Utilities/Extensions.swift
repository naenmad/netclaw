import SwiftUI

extension Color {
    static let netclawGreen = Color(red: 0.18, green: 0.84, blue: 0.45)
    static let netclawRed = Color(red: 0.94, green: 0.27, blue: 0.34)
    static let netclawYellow = Color(red: 0.95, green: 0.77, blue: 0.26)
    static let netclawBlue = Color(red: 0.25, green: 0.56, blue: 0.97)
    static let netclawPurple = Color(red: 0.62, green: 0.35, blue: 0.96)
    static let netclawOrange = Color(red: 0.96, green: 0.52, blue: 0.22)
    static let netclawCyan = Color(red: 0.22, green: 0.82, blue: 0.87)

    static let surfacePrimary = Color(nsColor: .controlBackgroundColor)
    static let surfaceSecondary = Color(nsColor: .windowBackgroundColor)
    static let surfaceElevated = Color(nsColor: .underPageBackgroundColor)
    static let textPrimary = Color(nsColor: .labelColor)
    static let textSecondary = Color(nsColor: .secondaryLabelColor)
    static let textTertiary = Color(nsColor: .tertiaryLabelColor)
    static let border = Color(nsColor: .separatorColor)
}

extension Date {
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var timestampString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}

extension String {
    var macFormatted: String {
        guard count == 12 || count == 17 else { return self }
        let clean = replacingOccurrences(of: ":", with: "")
        guard clean.count == 12 else { return self }
        return stride(from: 0, to: clean.count, by: 2)
            .map { String(clean[clean.index(clean.startIndex, offsetBy: $0)..<clean.index(clean.startIndex, offsetBy: min($0 + 2, clean.count))]) }
            .joined(separator: ":")
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.border.opacity(0.3), lineWidth: 1)
            )
    }
}
