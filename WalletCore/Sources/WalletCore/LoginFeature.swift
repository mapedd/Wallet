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

let AppVersionKey = "CFBundleShortVersionString"
let BuildNumberKey = "CFBundleVersion"

public struct Login: ReducerProtocol {
  
  public init() {}
  
  public enum LoginFailureReason: Hashable {
    public static func == (lhs: Login.LoginFailureReason, rhs: Login.LoginFailureReason) -> Bool {
      if
        case .apiError(let lerror) = lhs,
        case .apiError(let rerror) = rhs
      {
        return lerror.localizedDescription == rerror.localizedDescription
      }
      return false
    }
    
    public func hash(into hasher: inout Hasher) {
      if case .apiError(let error) = self {
        hasher.combine(error.localizedDescription.hashValue)
      }
    }
    
    case apiError(Swift.Error)
    
    public var description: String {
      switch self {
      case .apiError(let error):
        return error.localizedDescription
      }
    }
  }
  
  enum Error: Swift.Error {
    case userNotFound
  }
  
  public struct State: Equatable {
    public init(
      username: String = "",
      password: String = "",
      loggingIn: Bool = false,
      registering: Bool = false,
      buttonsEnabled: Bool = false,
      alert: AlertState<Login.Action>? = nil
    ) {
      self.username = username
      self.password = password
      self.loggingIn = loggingIn
      self.registering = registering
      self.buttonsEnabled = buttonsEnabled
      self.alert = alert
      self.footerText = ""
    }
    
    @BindingState public var username = ""
    @BindingState public var password = ""
    public var registering = false
    public var loggingIn = false
    public var buttonsEnabled = false
    @PresentationState public var alert: AlertState<Action>?
    public var footerText: String
    
    public var textFieldsDisabled: Bool {
      registering || loggingIn
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case task
    case binding(BindingAction<State>)
    case logIn
    case register
    case loggedIn(User.Token.Detail)
    case loginFailed(LoginFailureReason)
    case alertCancelTapped
    case sendEmailConfirmationTappedOnAlert
    case emailResent
    case emailResentFailed
  }
  
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.infoDictionary) var infoDictionary
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      
      switch action {
      case .emailResent:
        state.alert = nil
        return .none
        
      case .emailResentFailed:
        state.alert = .problemResendingEmail
        return .none
        
      case .task:
        state.footerText = footer()
        return .none
        
      case .sendEmailConfirmationTappedOnAlert:
        return triggerResendEmail(state)
        
      case .alertCancelTapped:
        state.alert = nil
        return .none
        
      case .binding(_):
        state.buttonsEnabled = buttonsEnabled(state)
        return .none
        
      case .logIn:
        state.loggingIn = true
        return triggerLoginEffect(state)
        
      case .register:
        state.registering = true
        return triggerRegisterEffect(state)
        
      case .loggedIn:
        state.loggingIn = false
        // this should be handled on the higher level
        return .none
        
      case .loginFailed(let reason):
        state.loggingIn = false
        state.registering = false
        state.alert = .failed(reason)
        return .none
      }
    }
  }
  
  func buttonsEnabled(_ state: State) -> Bool {
    let empty = state.username.isEmpty || state.password.isEmpty
    if empty {
      return false
    }
    if state.registering {
      return false
    }
    if state.loggingIn {
      return false
    }
    return true
  }
  
  func footer() -> String {
    let appVersion = infoDictionary[AppVersionKey] as! String
    let build = infoDictionary[BuildNumberKey] as! String
    return "Version \(appVersion)(\(build))\nServer \(apiClient.serverAddress)"
  }
  
  func triggerResendEmail(_ state: State) ->EffectTask<Action> {
    .task(
      operation: {
        let _ = try await apiClient.resendEmailConfirmation(state.username)
        return .emailResent
      },
      catch: { _ in
        return .emailResentFailed
      }
    )
  }
  
  func triggerRegisterEffect(_ state: State) -> EffectTask<Action> {
    .task(
      operation: {
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
  }
  
  func triggerLoginEffect(_ state: State) -> EffectTask<Action> {
    .task(
      operation: {
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
  }
  
}

public extension AlertState<Login.Action> {
  static func failed(_ reason: Login.LoginFailureReason) -> AlertState<Login.Action> {
    switch reason {
    case .apiError(let error):
      if let error = error as? AuthError { // user not registered
        if error == .userNotFound {
          return userNotRegistered
        }
      }
      if let error = error as? BackendError {
        if error.message == "user not verified email" {
          return emailNotVerified
        }
      }
    }
    
    return genericAlert(reason)
  }
  
  static func genericAlert(_ reason: Login.LoginFailureReason) -> AlertState<Login.Action> {
    .init(
      title: { .init("Warning")},
      actions: {
        ButtonState(
          role: .cancel) {
            TextState("Ok")
          }
      },
      message: { .init("Something went wrong...\(reason.description)") }
    )
  }
  
  static var emailNotVerified: AlertState<Login.Action> {
    .init(
      title: { .init("Email not verified")},
      actions: {
        ButtonState(
          role: .cancel
        ) {
          TextState("No")
        }
        ButtonState(
          action: .send(.sendEmailConfirmationTappedOnAlert),
          label: {
            TextState("Yes")
          }
        )
      },
      message: { .init("Dp you want to resend the confirmation email?") }
    )
  }
  
  static var userNotRegistered : AlertState<Login.Action> {
    .init(
      title: { .init("Hold on")},
      actions: {
        ButtonState(
          role: .cancel) {
            TextState("Ok")
          }
      },
      message: { .init("There's no user with this email/password")}
    )
  }
  
  static var problemResendingEmail: AlertState<Login.Action> {
    .init(
      title: { .init("Warning")},
      actions: {
        ButtonState(
          role: .cancel) {
            TextState("Ok")
          }
      },
      message: { .init("Problem occured during re-sending confirmation email")}
    )
  }
}
