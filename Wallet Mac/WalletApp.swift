//
//  WalletApp.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import SwiftUI
import XCTestDynamicOverlay

@main
struct WalletApp: App {
  var body: some Scene {
    WindowGroup {
      if !XCTIsTesting {
        ContentView(
          store: .init(
            initialState: .preview,
            reducer: mainReducer,
            environment: MainEnvironment()
          )
        )
      }
    }
  }
}
