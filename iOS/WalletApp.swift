//
//  WalletApp.swift
//  Shared
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import XCTestDynamicOverlay
import WalletCore

@main
struct WalletApp: App {
  var body: some Scene {
    WindowGroup {
      if !_XCTIsTesting {
        ContentView(
          store: .init(
            initialState: .loggedOut(.init()),
            reducer: Content()
          )
        )
      }
    }
  }
}


