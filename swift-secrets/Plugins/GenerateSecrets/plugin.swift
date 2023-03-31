import PackagePlugin

@main
struct Plugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    
    let localSecretFileName = "_LocalSecrets.swift"
    let inputPath = target.directory.appending([localSecretFileName])
    let outputPath = context.pluginWorkDirectory.appending("Secrets.generated.swift")
    
    return [
      .buildCommand(
        displayName: "Generate Secrets file",
        executable: try context.tool(named: "PluginExecutable").path,
        arguments: [
          "--input",
          inputPath,
          "--output",
          outputPath.string
        ],
        environment: [:],
        outputFiles: [outputPath]
      )
    ]
  }
}
