//
//  WalletApp.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import SwiftUI
import XCTestDynamicOverlay
import ComposableArchitecture
import WalletCore
import Combine

@main
struct WalletApp: App {
  
  let store: StoreOf<Content>
  
  @State var cancellable: AnyCancellable?
  
  @StateObject var viewStore: ViewStoreOf<Content>
  init() {
    store = .init(
      initialState: .loggedOut(.init()),
      reducer: Content()
    )
    let viewStore = ViewStore(self.store, observe: { $0 })
    self._viewStore = StateObject(wrappedValue: viewStore)
    cancellable = viewStore.publisher.sink { state in
      print("logOutCommandDisabled \(state.logOutCommandDisabled)")
    }
  
  }
  
  var body: some Scene {
    WindowGroup {
      if !_XCTIsTesting {
        ContentView(
          store: store
        )
      }
    }
    .windowStyle(.hiddenTitleBar)
    .commands {
      CommandMenu("Wallet") {
        Button("Log out") {
          self.viewStore.send(.loggedIn(.logOut))
        }
        .disabled(self.viewStore.state.logOutCommandDisabled)
      }
    }
  }
}
