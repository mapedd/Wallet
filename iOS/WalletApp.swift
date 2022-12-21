//
//  WalletApp.swift
//  Shared
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI

@main
struct WalletApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: .init(
          initialState: .loggedOut(.init()),
          reducer: ContentView.reducer,
          environment: ContentView.ContentEnvironment(
            apiClient: .live,
            keyValueStore: .live,
            keychain: .live
          )
        )
      )
    }
  }
}


