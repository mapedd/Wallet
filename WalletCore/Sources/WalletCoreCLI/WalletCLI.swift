//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 23/03/2023.
//

import Foundation
import ArgumentParser
import AppApi
import WalletCoreDataModel

@main
struct WalletCLI: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "walletcli",
    abstract: "A utility for working with wallet app.",
    version: "0.0.1",
//    subcommands: [Import.self, Interact.self]
    subcommands: [Import.self]
  )
  
}
