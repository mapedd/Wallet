// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalletCore",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "WalletCore",
            targets: ["WalletCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(name: "AppApi", path: "../Backend"),
         .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.8.2"),
         .package(url: "https://github.com/pointfreeco/swiftui-navigation", exact: "0.6.1"),
         .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.50.1"),
         .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.0"),
         .package(url: "https://github.com/vapor/vapor", from: "4.54.0"),
         .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "WalletCore",
            dependencies: [
              "AppApi",
              .product(name: "LinuxHelpers", package: "AppApi"),
              .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
              .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper"),
              .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "WalletCoreTests",
            dependencies: [
              "WalletCore"
            ]
        ),
        .testTarget(
            name: "WalletCoreIntegrationTests",
            dependencies: [
              "WalletCore",
              .product(name: "Vapor", package: "vapor"),
              .product(name: "XCTVapor", package: "vapor"),
              .product(name: "App", package: "AppApi")
            ]
        )
    ]
)
