//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 23/03/2023.
//

import Foundation
import ArgumentParser
import WalletCoreDataModel
import WalletCore
import AppApi

func readline(silent: Bool) -> String? {
  return silent ? String(cString: getpass("")) : readLine()
}

struct Interact: AsyncParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "interact",
    abstract: "authenticate, create and read your wallet records"
  )
  
  @Option(help: "a username for the account, usually an email")
  var username: String
  
  mutating func run() async throws {
    
    print("Welcome, you are signing in to Wallet API, your email is \(username)")
    print("Please enter password")
    guard let password = readline(silent: true) else {
      return
    }
    
    let keychain = Keychain.preview
    
    let apiClient = APIClient.live(
      keychain: keychain,
      session: URLSession.shared
    )
    let result = try await apiClient.signIn(User.Account.Login(email: username, password: password))
    guard let result else {
      throw NSError(domain: "com.mapedd", code: 999)
    }
    
    keychain.saveToken(result.toLocalToken)
    
    print("Authorized as \(username)")
    
    printMenu()
    
    while let action = readline(silent: false) {
      
      if action == "1" {
        try await Read.Records(keychain: keychain).run()
      }
      else if action == "0" {
        try await LogOut(keychain: keychain).run()
      }
      else if action == "9" {
        throw ExitCode(0)
      }
      
      printMenu()
    }
    
    func printMenu() {
      print("What do you want to do next?")
      print("[1] list records")
      print("[0] log out")
      print("[9] quit")
    }
  }
  
  
  private struct LogOut {
    
    var keychain: Keychain
    
    func run() async throws {
      let apiClient = APIClient.live(
        keychain: keychain,
        session: URLSession.shared
      )
      let result = try await apiClient.signOut()
      keychain.saveToken(nil)
      print("result sign out \(result)")
    }
  }
  
  struct Read {
    
    struct Records {
      var keychain: Keychain
      func run() async throws {
        let apiClient = APIClient.live(
          keychain: keychain,
          session: URLSession.shared
        )
        let records = try await apiClient.listRecords()
        print("result records \(records)")
      }
    }
  }
}
