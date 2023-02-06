//
//  ContentView.swift
//  Shared
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
  var store: StoreOf<Content>
  var body: some View {
    NavigationView {
      WithViewStore(self.store, observe: { $0 }) { viewStore in
        SwitchStore(self.store) {
          CaseLet(state: /Content.State.loggedIn, action: Content.Action.loggedIn) { store in
            MainView(
              store: store
            )
          }
          CaseLet(state: /Content.State.loggedOut, action: Content.Action.loggedOut) { store in
              LoginView(
                store: store
              )
              .navigationBarTitle("Login")
          }
        }
        .onAppear{
          viewStore.send(.viewLoaded)
        }
      }
    }
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: .init(
        initialState: .loggedOut(.init()),
        reducer: Content()
      )
    )
  }
}

