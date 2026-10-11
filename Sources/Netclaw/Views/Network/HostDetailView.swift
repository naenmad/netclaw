import SwiftUI

struct HostDetailView: View {
    let host: Host

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // header
                VStack(alignment: .leading, spacing: 6) {
                    Text(host.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let vendor = host.vendor, !vendor.isEmpty {
                        Text(vendor)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // details grid
                LazyVGrid(columns: [
                    GridItem(.fixed(80), alignment: .trailing),
                    GridItem(.flexible(), alignment: .leading)
                ], spacing: 10) {
                    detailRow("IPv4", value: host.ipv4 ?? "N/A")
                    detailRow("IPv6", value: host.ipv6 ?? "N/A")
                    detailRow("MAC", value: host.mac ?? "N/A")
                    detailRow("Hostname", value: host.hostname ?? "N/A")
                    detailRow("Alias", value: host.alias ?? "N/A")
                    detailRow("Vendor", value: host.vendor ?? "N/A")
                    detailRow("First Seen", value: host.firstSeenDate?.relativeString ?? "N/A")
                    detailRow("Last Seen", value: host.lastSeenDate?.relativeString ?? "N/A")
                }

                // meta data
                if let meta = host.meta?.values, !meta.isEmpty {
                    Divider()
                    Text("Metadata")
                        .font(.headline)

                    ForEach(Array(meta.keys.sorted()), id: \.self) { key in
                        if let val = meta[key] {
                            HStack {
                                Text(key)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(val.value ?? "")
                                    .font(.system(.caption, design: .monospaced))
                                    .textSelection(.enabled)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func detailRow(_ label: String, value: String) -> some View {
        Text(label)
            .font(.caption)
            .foregroundStyle(.secondary)
        Text(value)
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
    }
}
