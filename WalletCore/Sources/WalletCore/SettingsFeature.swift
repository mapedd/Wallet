//
//  SettingsFeature.swift
//  
//
//  Created by Tomek Kuzma on 21/03/2023.
//

import Foundation
import ComposableArchitecture

public struct UserModel: Hashable, Identifiable {
  public init(email: String, id: UUID) {
    self.email = email
    self.id = id
  }
  
  public var email: String
  public var id: UUID
}

public struct Settings: ReducerProtocol {
  public init() {}
  public struct State: Hashable, Identifiable {
    
    public var id: UUID {
      self.user.id
    }
    
    public init(user: UserModel) {
      self.user = user
    }
    
    public var user: UserModel
    public var alert: AlertState<Action.Alert>? = nil
    
    public var headerCopy: String {
      "Logged in as \(user.email)"
    }
    
    public var isLoggedIn: Bool {
      true
    }
    
  }
  
  public enum Action: Equatable {
    case logOutButtonTapped
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    public enum Alert: Equatable {
      case logoutAlertConfirmed
    }
    public enum Delegate: Equatable {
      case logOutRequested
    }
  }
  
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .logOutButtonTapped:
      state.alert = .alertRequested
      return .none
    case .alert(.presented(.logoutAlertConfirmed)):
      return Effect(value: .delegate(.logOutRequested))
    case .delegate:
      return .none
    case .alert(.dismiss):
      return .none
    }
  }
}


extension AlertState where Action == Settings.Action.Alert {
  static var alertRequested: Self {
    AlertState {
      TextState("Logout")
    } actions: {
      ButtonState(role: .destructive, action: .send(.logoutAlertConfirmed, animation: .default)) {
        TextState("Yes")
      }
    } message: {
      TextState("Are you sure you want to log out?")
    }
  }
}
