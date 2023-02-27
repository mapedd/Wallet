// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Wallet",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .library(name: "AppApi", targets: ["AppApi"]),
        .library(name: "App", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "4.54.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.4.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.1.0"),
        .package(url: "https://github.com/binarybirds/liquid", from: "1.3.0"),
        .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.3.0"),
        .package(url: "https://github.com/binarybirds/swift-html", from: "1.2.0"),
        .package(url: "https://github.com/binarybirds/spec", from: "1.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.7.0"),
        .package(url: "https://github.com/mailslurp/mailslurp-client-swift", from: "15.16.22")
    ],
    targets: [
        .target(name: "AppApi", dependencies: []),
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "Liquid", package: "liquid"),
            .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
            .product(name: "SwiftHtml", package: "swift-html"),
            .product(name: "SwiftSvg", package: "swift-html"),
            .product(name: "mailslurp", package: "mailslurp-client-swift"),
            .target(name: "AppApi")
        ]),
        .executableTarget(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
            .product(name: "CustomDump", package: "swift-custom-dump"),
            .product(name: "Spec", package: "spec"),
        ]),
        .testTarget(name: "AppApiTests", dependencies: [
            .target(name: "AppApi"),
        ])
    ]
)
