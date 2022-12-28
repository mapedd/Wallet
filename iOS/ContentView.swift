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

struct KeyValueStore {
  var write: (_ key: String, _ value: String) -> Void
  var read: (_ key: String) -> String?
  
  static var live: KeyValueStore {
    let defaults = UserDefaults.standard
    return KeyValueStore(
      write: {key, value in
        defaults.set(value, forKey: key)
      },
      read: { key in
        defaults.value(forKey: key) as? String
      }
    )
  }
}

struct ContentView: View {
  enum State: Equatable {
    case loggedIn(MainState)
    case loggedOut(LoginState)
  }
  
  enum Action {
    case loggedIn(MainAction)
    case loggedOut(LoginAction)
    case successfullyLoggedOut
    case viewLoaded
  }
  
  
  
  struct ContentEnvironment {
    init(
      apiClient: APIClient,
      keyValueStore: KeyValueStore,
      keychain: Keychain,
      dateProvider: DateProvider
    ) {
      self.apiClient = apiClient
      self.keyValueStore = keyValueStore
      self.keychain = keychain
      self.dateProvider = dateProvider
    }
    
    var apiClient: APIClient
    var keyValueStore: KeyValueStore
    var keychain: Keychain
    var dateProvider: DateProvider
    
    var main: MainEnvironment {
      .init(
        apiClient: apiClient,
        dateProvider: dateProvider
      )
    }
    var login: LoginEnvironment {
      .init(apiClient: apiClient)
    }
  }
  
  
  static let reducer: Reducer<State,Action,ContentEnvironment> = Reducer.combine(
    mainReducer.pullback(
      state: /State.loggedIn,
      action: /Action.loggedIn,
      environment: { $0.main }
    ),
    loginReducer.pullback(
      state: /State.loggedOut,
      action: /Action.loggedOut,
      environment: { $0.login }
    ),
    .init{ state, action, env in
      switch action {
      case .loggedOut(.loggedIn(let token)):
        env.keychain.saveToken(token.toLocalToken)
        state = .loggedIn(MainState())
      case .loggedIn(.logOut):
        //        state.main.loading = true// show loading indicator
        guard let token = env.keychain.readToken() else {
          state = .loggedOut(LoginState())
          return .none
        }
        
        return .task(
          operation: {
            
            let result = try await env.apiClient.signOut()
            debugPrint("result \(result)")
            return .successfullyLoggedOut
          }, catch: { error in
            // we need to log out even if it failed to not be stuck here forever
            
            return .successfullyLoggedOut
          }
        )
      case .successfullyLoggedOut:
        env.keychain.saveToken(nil)
        state = .loggedOut(LoginState())
        return .none
      case .viewLoaded:
        if env.keychain.readToken() != nil {
          state = .loggedIn(MainState())
        }
        return .none
      default:
        return .none
      }
      return .none
    }
  )
  .debug()
  
  var store: Store<State, Action>
  var body: some View {
    NavigationView {
      WithViewStore(self.store, observe: { $0 }) { viewStore in
        SwitchStore(self.store) {
          CaseLet(state: /State.loggedIn, action: Action.loggedIn) { store in
            MainView(
              store: store
            )
          }
          CaseLet(state: /State.loggedOut, action: Action.loggedOut) { store in
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

//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView(
//      store: .init(
//        initialState: <#T##ContentView.State#>,
//        reducer: <#T##Reducer<ContentView.State, ContentView.Action, Environment>#>,
//        environment: <#T##Environment#>
//      )
//    )
//  }
//}
//
