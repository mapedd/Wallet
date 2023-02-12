//
//  ContentFeature.swift
//  Wallet
//
//  Created by Tomek Kuzma on 06/02/2023.
//


import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import SwiftUINavigation
import AppApi

public extension User.Token.Detail {
  var toLocalToken: Token {
    .init(
      value: self.token.value,
      validDate: self.token.expiry,
      refreshToken: self.token.refresh
    )
  }
}

public struct Content: ReducerProtocol {

  public init() {}
  
  public enum State: Equatable {
    case loggedIn(Main.State)
    case loggedOut(Login.State)
  }
  
  public enum Action {
    case loggedIn(Main.Action)
    case loggedOut(Login.Action)
    case successfullyLoggedOut
    case viewLoaded
  }
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.keychain) var keychain
  
  public var body: some ReducerProtocol<State,Action> {
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

