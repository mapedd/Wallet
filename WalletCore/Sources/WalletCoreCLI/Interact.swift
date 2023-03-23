//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 23/03/2023.
//

import Foundation
import ArgumentParser

struct Interact: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "interact",
    abstract: "authenticate, create and read your wallet records",
    subcommands: [Authenticate.self, Create.self, Read.self],
    defaultSubcommand: Read.self
  )
  
  struct Authenticate: ParsableCommand {
    
  }
  struct Create: ParsableCommand {
    
  }
  struct Read: ParsableCommand {
    
  }
}
