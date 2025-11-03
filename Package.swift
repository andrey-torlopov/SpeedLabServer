// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SpeedLabServer",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.105.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: ["App"]
        )
    ]
)
