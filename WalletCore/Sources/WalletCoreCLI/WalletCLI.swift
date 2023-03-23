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
    subcommands: [Import.self, Interact.self],
    defaultSubcommand: Import.self
  )
}
