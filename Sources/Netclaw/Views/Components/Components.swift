import SwiftUI

struct ModuleToggle: View {
    let label: String
    let icon: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(isOn ? .white : .primary)
            .background(
                isOn ? Color.netclawGreen : Color.clear,
                in: RoundedRectangle(cornerRadius: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(isOn ? Color.clear : Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatusBadge: View {
    let isActive: Bool
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.netclawGreen : Color.netclawRed.opacity(0.5))
                .frame(width: 6, height: 6)
            Text(label)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.quaternary.opacity(0.5), in: Capsule())
    }
}

struct EventRow: View {
    let event: BettercapEvent

    var body: some View {
        HStack(spacing: 8) {
            // timestamp
            Text(event.timestamp?.timestampString ?? "")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(width: 75, alignment: .leading)

            // category icon
            Image(systemName: event.category.iconName)
                .font(.caption2)
                .foregroundStyle(categoryColor)
                .frame(width: 14)

            // tag
            Text(event.tag ?? "event")
                .font(.system(size: 10, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(categoryColor)
                .frame(minWidth: 80, alignment: .leading)

            // data
            Text(event.data?.description ?? "")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(Color.clear)
        .contentShape(Rectangle())
    }

    private var categoryColor: Color {
        switch event.category {
        case .network: return .netclawGreen
        case .wifi: return .netclawPurple
        case .bluetooth: return .netclawCyan
        case .proxy: return .netclawYellow
        case .module: return .netclawOrange
        case .system: return .secondary
        }
    }
}
