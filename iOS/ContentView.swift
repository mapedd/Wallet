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

struct LoginState: Equatable {
  
}

enum LoginAction {
  
}

struct LoginEnvironment {
  
}

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, _ in
    .none
}

struct LoginView: View {
  var store: Store<LoginState, LoginAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Text("Login View")
    }
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
  }
  
  struct Environment {
    var main: MainEnvironment
    var login: LoginEnvironment
  }
  
  static var reducer = Reducer<State,Action,Environment> { state, action, environment in
      .none
  }
  
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
