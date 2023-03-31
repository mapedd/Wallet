// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-secrets",
  platforms: [.iOS(.v16), .macOS(.v10_13)],
  products: [
    .plugin(
      name: "GenerateSecrets",
      targets: ["GenerateSecrets"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    .package(url: "https://github.com/jpsim/SourceKitten.git", exact: "0.32.0")
  ],
  targets: [
    .executableTarget(
      name: "PluginExecutable",
      dependencies: [
        .product(
          name: "ArgumentParser",
          package: "swift-argument-parser"
        ),
        .product(
          name: "SourceKittenFramework",
          package: "SourceKitten"
        )
      ]
    ),
    .plugin(
      name: "GenerateSecrets",
      capability: .buildTool(),
      dependencies: ["PluginExecutable"]
    )
  ]
)
