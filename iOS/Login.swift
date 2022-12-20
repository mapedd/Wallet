//
//  Login.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import SwiftUI
import ComposableArchitecture
import AppApi

struct LoginState: Equatable {
  @BindableState var username = "mapedd@gmail.com"
  @BindableState var password = "BobMarley123"
  var loading = false
  var loginFailed = false
}

enum LoginAction: BindableAction {
  case binding(BindingAction<LoginState>)
  case logIn
  case register
  case loggedIn(User.Token.Detail)
  case loginFailed
}

struct LoginEnvironment {
  var apiClient: APIClient
}

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, env in
  switch action {
    
  case .binding(_):
    return .none
  case .logIn:
    return .task {[state] in 
      let login = User.Account.Login(
        email: state.username,
        password: state.password
      )
      let user = try await env.apiClient.signIn(login)
      if let user {
        return .loggedIn(user)
      } else {
        return .loginFailed
      }
    }
  case .register:
    return .none
  case .loggedIn(let token):
    // this should be handled on the higher level
    return .none
  case .loginFailed:
    state.loginFailed = true
    return .none
  }
}
  .binding()

struct LoginView: View {
  var store: Store<LoginState, LoginAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView {
        VStack {
          Spacer()
          Text("Wallet")
          TextField("Email",
            text: viewStore.binding(\.$username)
          )
          TextField("Password",
            text: viewStore.binding(\.$password)
          )
          Button("Log me in ") {
            viewStore.send(.logIn)
          }
          Spacer()
        }
        .padding()
      }
    }
  }
}
