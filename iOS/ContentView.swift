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

struct ContentView: View {
  enum State: Equatable {
    case loggedIn(MainState)
    case loggedOut(LoginState)
  }
  
  enum Action {
    case loggedIn(MainAction)
    case loggedOut(LoginAction)
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
  
  struct ContentEnvironment {
    init(
      apiClient: APIClient,
      keyValueStore: KeyValueStore
    ) {
      self.apiClient = apiClient
      self.keyValueStore = keyValueStore
    }
    
    private var apiClient: APIClient
    var keyValueStore: KeyValueStore
    
    var main: MainEnvironment {
      .init(apiClient: apiClient)
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
        env.keyValueStore.write("token", token.value)
        state = .loggedIn(MainState())
      case .loggedIn(.logOut):
        state = .loggedOut(LoginState())
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
