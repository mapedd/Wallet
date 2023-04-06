// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WalletCore",
  platforms: [.iOS(.v16), .macOS(.v12)],
  products: [
    .library(
      name: "WalletCore",
      targets: ["WalletCore"]),
    .library(
      name: "WalletCoreDataModel",
      targets: ["WalletCoreDataModel"]),
    .executable(
      name: "WalletCoreCLI",
      targets: ["WalletCoreCLI"]
    )
  ],
  dependencies: [
    .package(name: "AppApi", path: "../Backend"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.8.2"),
    .package(
      url: "https://github.com/pointfreeco/swiftui-navigation",
      branch: "main"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      //      branch: "prerelease/1.0"
      //      branch: "navigation-beta"
      revision: "bcf5683aecdba339d309848c50b7f33fed887709"
    ),
//    .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.0"),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
    .package(url: "https://github.com/vapor/vapor", from: "4.54.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.7.0")
  ],
  targets: [
    .executableTarget(
      name: "WalletCoreCLI",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        "WalletCoreDataModel",
        "WalletCore",
        "AppApi"
      ]
    ),
    .target(
      name: "WalletCoreDataModel",
      dependencies: [
        "AppApi",
        .product(name: "Parsing", package: "swift-parsing"),
        .product(name: "LinuxHelpers", package: "AppApi")
      ]
    ),
    .target(
      name: "WalletCore",
      dependencies: [
        "AppApi",
        "WalletCoreDataModel",
        .product(name: "LinuxHelpers", package: "AppApi"),
        .product(name: "Utils", package: "AppApi"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//        .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper"),
        .product(name: "KeychainAccess", package: "KeychainAccess"),
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
        .product(name: "AppTestingHelpers", package: "AppApi"),
        "WalletCore",
        .product(name: "Vapor", package: "vapor"),
        .product(name: "XCTVapor", package: "vapor"),
        .product(name: "App", package: "AppApi")
      ]
    )
  ]
)
