# Netclaw 🌐

> A modern, native macOS SwiftUI desktop client for [bettercap](https://github.com/bettercap/bettercap).

Netclaw provides an intuitive, dark-mode macOS interface to monitor networks, inspect connected devices, manage bettercap modules, and run security diagnostics without being tied to the command-line interface.

---

## ✨ Features

- **Dashboard**: Real-time overview of active network interfaces, gateway details, discovered host/AP counts, and clickable module pills to start/stop any bettercap module with a single click.
- **Network Recon & Probe**: Discover and monitor hosts on your local subnet using `net.recon` and `net.probe`. View IP addresses, MAC addresses, hostnames, and hardware vendors.
- **WiFi Scanner**: View wireless access points, channel allocation, signal strength (RSSI), and encryption protocols (WPA2/WPA3/Open).
- **Bluetooth LE**: Scan nearby Bluetooth Low Energy devices and inspect RSSI signals and manufacturer data.
- **Network Sniffer**: Live packet capture with custom BPF filters, packet size inspection, and streaming event logs.
- **Proxy Management**: Toggle HTTP/HTTPS proxy and local HTTP server directly from the UI.
- **Interactive Console**: Full-featured bettercap interactive terminal with command history (Up/Down arrows) and ANSI color stripping for clean output.
- **Events Timeline**: Real-time event poller capturing network events, module state changes, and system logs.

---

## 🛠️ Prerequisites

1. **macOS 14 (Sonoma)** or later.
2. **bettercap** installed and running with the REST API enabled:

```bash
# Install bettercap (via Homebrew)
brew install bettercap

# Start bettercap with REST API enabled
sudo bettercap -eval "set api.rest.username user; set api.rest.password pass; api.rest on"
```

---

## 🚀 Building & Running

### Using Swift Package Manager:

```bash
# Clone the repository
git clone https://github.com/naenmad/netclaw.git
cd netclaw

# Build release binary
swift build -c release

# Run directly
swift run
```

### Building the macOS `.app` Bundle:

```bash
# Create app bundle structure
mkdir -p Netclaw.app/Contents/MacOS
mkdir -p Netclaw.app/Contents/Resources

# Copy release binary
cp .build/release/Netclaw Netclaw.app/Contents/MacOS/Netclaw
chmod +x Netclaw.app/Contents/MacOS/Netclaw

# (Optional) Install to /Applications
cp -r Netclaw.app /Applications/Netclaw.app
xattr -cr /Applications/Netclaw.app
open /Applications/Netclaw.app
```

---

## 🔌 Connecting to bettercap

When launching Netclaw:
- **Host**: `127.0.0.1` (or your remote host IP)
- **Port**: `8081` (default bettercap REST API port)
- **Username**: `user`
- **Password**: `pass`
- **Use HTTPS**: Leave **OFF** unless you specifically configured TLS certificates in bettercap.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

## ⚠️ Disclaimer

Netclaw is designed for authorized network administration, monitoring, and educational security research. Only use this software on networks you own or have explicit permission to test.
