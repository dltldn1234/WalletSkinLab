// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WalletSkinCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "WalletSkinCore", targets: ["WalletSkinCore"])],
    targets: [
        .target(name: "WalletSkinCore"),
        .testTarget(name: "WalletSkinCoreTests", dependencies: ["WalletSkinCore"])
    ]
)
