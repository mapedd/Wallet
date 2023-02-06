//
//  LoginFeature.swift
//  Wallet
//
//  Created by Tomek Kuzma on 01/01/2023.
//

import Foundation
import ComposableArchitecture
import AppApi
import SwiftUINavigation

struct Login: ReducerProtocol {
  
  enum LoginFailureReason: Hashable {
    static func == (lhs: Login.LoginFailureReason, rhs: Login.LoginFailureReason) -> Bool {
      if
        case .apiError(let lerror) = lhs,
        case .apiError(let rerror) = rhs
      {
        return lerror.localizedDescription == rerror.localizedDescription
      }
      return false
    }
    
    func hash(into hasher: inout Hasher) {
      if case .apiError(let error) = self {
        hasher.combine(error.localizedDescription.hashValue)
      }
    }
    
    case apiError(Swift.Error)
    
    var description: String {
      switch self {
      case .apiError(let error):
        return error.localizedDescription
      }
    }
  }
  
  enum Error: Swift.Error {
    case userNotFound
  }
  
  struct State: Equatable {
    @BindableState var username = ""
    @BindableState var password = ""
    var loading = false
    var buttonsEnabled = false
    var alert: AlertState<Action>?
  }
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case logIn
    case register
    case loggedIn(User.Token.Detail)
    case loginFailed(LoginFailureReason)
    case alertCancelTapped
  }
  
  
  @Dependency(\.apiClient) var apiClient
  
  var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .alertCancelTapped:
        state.alert = nil
        return .none
      case .binding(_):
        state.buttonsEnabled = !state.username.isEmpty && !state.password.isEmpty
        return .none
      case .logIn:
        state.loading = true
        return .task(
          operation: {[state] in
            let login = User.Account.Login(
              email: state.username,
              password: state.password
            )
            let user = try await apiClient.signIn(login)
            if let user {
              return .loggedIn(user)
            } else {
              return .loginFailed(.apiError(Error.userNotFound))
            }
          },
          catch: { error in
            return .loginFailed(.apiError(error))
          }
        )
      case .register:
        state.loading = true
        return .task(
          operation: {[state] in
            let login = User.Account.Login(
              email: state.username,
              password: state.password
            )
            let user = try await apiClient.register(login)
            // we registered user, now we can log him in 
            if user != nil {
              return .logIn
            } else {
              return .loginFailed(.apiError(Error.userNotFound))
            }
          },
          catch: { error in
            return .loginFailed(.apiError(error))
          }
        )
      case .loggedIn:
        state.loading = false
        // this should be handled on the higher level
        return .none
      case .loginFailed(let reason):
        state.loading = false
        state.alert = .failed(reason)
        return .none
      }
    }
  }
  
}

extension AlertState {
  static func failed(_ reason: Login.LoginFailureReason) -> AlertState {
    AlertState(
      title: .init("Warning"),
      message: .init("Something went wrong...\(reason.description)"),
      primaryButton: .default(.init(verbatim: "OK")),
      secondaryButton: .init(label: {
        TextState("")
      })
    )
  }
}
