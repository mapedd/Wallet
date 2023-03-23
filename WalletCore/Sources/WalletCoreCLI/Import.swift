//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 22/03/2023.
//

import Foundation
import ArgumentParser
import AppApi
import WalletCoreDataModel


struct Import: ParsableCommand {
  
  static var configuration = CommandConfiguration(
    commandName: "import",
    abstract: "A utility for transforming bank csv into JSON understood by Wallet Core.",
    subcommands: [Millenium.self]
  )
  
  
  struct Options: ParsableArguments {
    
    @Argument(help: "The csv file name to import and export as internal JSON format")
    var inputFile: String
    
    @Argument(help: "The file name to export output in the internal JSON format")
    var outputFile: String?
  }
  
}

extension String {
  var expandingTildeInPath: String {
      return self.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)
  }
}
