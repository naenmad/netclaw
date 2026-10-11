// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Netclaw",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Netclaw",
            path: "Sources/Netclaw"
        )
    ]
)
