//
//  ContentFeature.swift
//  Wallet
//
//  Created by Tomek Kuzma on 06/02/2023.
//



import SwiftUINavigation
import IdentifiedCollections
import Logging
import AppApi
import ComposableArchitecture
import WalletCoreDataModel

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
  
  let logger = Logger(label: "com.mapedd.wallet.content")
  
  public init() {}
  
  public enum State: Equatable {
    case loggedIn(Main.State)
    case loggedOut(Login.State)
    
    public var logOutCommandDisabled: Bool {
      if case .loggedIn = self {
        return false
      }
      return true
    }
  }
  
  public enum Action {
    case loggedIn(Main.Action)
    case loggedOut(Login.Action)
    case successfullyLoggedOut
    case task
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
      case .loggedOut(let loggedOutAction):
        if case .loggedIn(let token) = loggedOutAction {
          keychain.saveToken(token.toLocalToken)
          state = .loggedIn(Main.State())
        }
        return .none
        
      case .loggedIn(let loggedInAction):
        if loggedInAction == .logOut {
          return logOut(&state)
        }
        return .none
        
      case .successfullyLoggedOut:
        keychain.saveToken(nil)
        state = .loggedOut(Login.State())
        return .none
      case .task:
        return taskEffect(&state, logger: logger)
      }
    }
  }
  
  private func taskEffect(_ state: inout State, logger: Logger) -> EffectTask<Action> {
    
    switch state {
    case .loggedOut:
      if keychain.readToken() != nil  {
        logger.notice("main view appeared, has stored credentials")
        state = .loggedIn(
          Main.State(
            records: []
          )
        )
      } else {
        logger.notice("main view appeared, has no stored credentials, need log in ")
      }
      return .none
    case .loggedIn:
      logger.notice("main view appeared, already logged in ")
      return .none
      
    }
  }
  
  private func logOut(_ state: inout State) -> EffectTask<Action> {
    
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
  }
}
