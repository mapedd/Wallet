//
//  Login.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import SwiftUI
import ComposableArchitecture
import AppApi


struct Login: ReducerProtocol {
  
  struct State: Equatable {
    @BindableState var username = "tomek@gmail.com"
    @BindableState var password = "maciek12"
    var loading = false
    var loginFailed = false
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case logIn
    case register
    case loggedIn(User.Token.Detail)
    case loginFailed
  }


  @Dependency(\.apiClient) var apiClient
  
  var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        
      case .binding(_):
        return .none
      case .logIn:
        return .task {[state] in
          let login = User.Account.Login(
            email: state.username,
            password: state.password
          )
          let user = try await apiClient.signIn(login)
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
  }
  
}
//let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, env in
//  switch action {
//
//  case .binding(_):
//    return .none
//  case .logIn:
//    return .task {[state] in
//      let login = User.Account.Login(
//        email: state.username,
//        password: state.password
//      )
//      let user = try await env.apiClient.signIn(login)
//      if let user {
//        return .loggedIn(user)
//      } else {
//        return .loginFailed
//      }
//    }
//  case .register:
//    return .none
//  case .loggedIn(let token):
//    // this should be handled on the higher level
//    return .none
//  case .loginFailed:
//    state.loginFailed = true
//    return .none
//  }
//}
//  .binding()

struct LoginView: View {
  var store: StoreOf<Login>
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
