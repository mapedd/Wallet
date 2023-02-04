//
//  ContentView.swift
//  Shared
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import SwiftUINavigation
import AppApi

extension User.Token.Detail {
  var toLocalToken: Token {
    .init(
      value: self.token.value,
      validDate: self.token.expiry,
      refreshToken: self.token.refresh
    )
  }
}

struct Content: ReducerProtocol {
  
  enum State: Equatable {
    case loggedIn(Main.State)
    case loggedOut(Login.State)
  }
  
  enum Action {
    case loggedIn(Main.Action)
    case loggedOut(Login.Action)
    case successfullyLoggedOut
    case viewLoaded
  }
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.keychain) var keychain
  
  var body: some ReducerProtocol<State,Action> {
    Scope(state: /State.loggedIn, action: /Action.loggedIn) {
      Main()
    }
    Scope(state: /State.loggedOut, action: /Action.loggedOut) {
      Login()
    }
    Reduce { state, action in
      switch action {
      case .loggedOut(.loggedIn(let token)):
        keychain.saveToken(token.toLocalToken)
        state = .loggedIn(Main.State())
      case .loggedIn(.logOut):
        //        state.main.loading = true// show loading indicator
        guard let _ = keychain.readToken() else {
          state = .loggedOut(Login.State())
          return .none
        }
        
        return .task(
          operation: {
            
            let result = try await apiClient.signOut()
            debugPrint("result \(result)")
            return .successfullyLoggedOut
          }, catch: { error in
            // we need to log out even if it failed to not be stuck here forever
            
            return .successfullyLoggedOut
          }
        )
      case .successfullyLoggedOut:
        keychain.saveToken(nil)
        state = .loggedOut(Login.State())
        return .none
      case .viewLoaded:
        if keychain.readToken() != nil {
          state = .loggedIn(Main.State())
        }
        return .none
      default:
        return .none
      }
      return .none
    }
  }
}

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

