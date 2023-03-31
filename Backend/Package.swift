// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "Wallet",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .library(name: "AppApi", targets: ["AppApi"]),
    .library(name: "App", targets: ["App"]),
    .library(name: "AppTestingHelpers", targets: ["AppTestingHelpers"]),
    .library(name: "LinuxHelpers", targets: ["LinuxHelpers"]),
    .library(name: "Utils", targets: ["Utils"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.7.0"),
    .package(url: "https://github.com/vapor/vapor", from: "4.54.0"),
    .package(url: "https://github.com/vapor/fluent", from: "4.4.0"),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.1.0"),
    .package(url: "https://github.com/binarybirds/liquid", from: "1.3.0"),
    .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.3.0"),
    .package(url: "https://github.com/binarybirds/swift-html", from: "1.2.0"),
    .package(url: "https://github.com/binarybirds/spec", from: "1.2.0"),
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.5.3"),
    .package(name: "swift-secrets", path: "../swift-secrets")
  ],
  targets: [
    .target(name: "LinuxHelpers", dependencies: []),
    .target(name: "Utils", dependencies: []),
    .target(name: "AppTestingHelpers", dependencies: [
      .product(name: "Vapor", package: "vapor"),
      "SwiftSoup"
    ]),
    .target(name: "AppApi", dependencies: []),
    .target(
      name: "App",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "Liquid", package: "liquid"),
        .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
        .product(name: "SwiftHtml", package: "swift-html"),
        .product(name: "SwiftSvg", package: "swift-html"),
        .target(name: "AppApi"),
        .target(name: "LinuxHelpers"),
        .target(name: "Utils"),
      ],
      exclude: [
        "_LocalSecrets.swift"
      ],
      plugins: [
        .plugin(name: "GenerateSecrets", package: "swift-secrets")
      ]
    ),
    .executableTarget(name: "Run", dependencies: ["App"]),
    .testTarget(name: "AppTests", dependencies: [
      .target(name: "App"),
      .target(name: "AppTestingHelpers"),
      .product(name: "XCTVapor", package: "vapor"),
      .product(name: "CustomDump", package: "swift-custom-dump"),
      .product(name: "Spec", package: "spec"),
    ]),
    .testTarget(name: "AppApiTests", dependencies: [
      .target(name: "AppApi"),
    ])
  ]
)
