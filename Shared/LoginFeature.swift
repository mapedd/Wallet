//
//  LoginFeature.swift
//  Wallet
//
//  Created by Tomek Kuzma on 01/01/2023.
//

import Foundation
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
