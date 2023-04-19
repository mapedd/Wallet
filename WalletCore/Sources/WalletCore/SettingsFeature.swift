//
//  SettingsFeature.swift
//  
//
//  Created by Tomek Kuzma on 21/03/2023.
//

import Foundation
import ComposableArchitecture
import WalletCoreDataModel
import AppApi
import Logging

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
    public var showProgress = false
    public var picker: DocumentPicker.State?
    public var alert: AlertState<Action.Alert>? = nil
    
    public var headerCopy: String {
      "Logged in as \(user.email)"
    }
    
    
    public var isLoggedIn: Bool {
      true
    }
    
  }
  
  let logger = Logger(label: "com.mapedd.wallet.settings")
  
  public enum Action: Equatable {
    case logOutButtonTapped
    case deleteAccountRowTapped
    case importFromFileRowTapped
    case picker(PresentationAction<DocumentPicker.Action>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    case parsingFailed
    case changePassword
    
    public enum Alert: Equatable {
      case logoutAlertConfirmed
      case deleteAccountAlertConfirmed
    }
    public enum Delegate: Equatable {
      case logOutRequested
      case deleteAcountRequested
      case attemptImport([AppApi.Record.Detail])
    }
  }
  
  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      settingsReducer(into: &state, action: action)
    }
    .ifLet(\.picker, action: /Action.picker) {
      DocumentPicker()
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  
  private func settingsReducer(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .logOutButtonTapped:
      state.alert = .alertRequested
      return .none
    case .deleteAccountRowTapped:
      state.alert = .deleteAccount
      return .none
    case .changePassword: 
      return .none
    case .alert(.presented(.logoutAlertConfirmed)):
      return Effect(value: .delegate(.logOutRequested))
    case .delegate:
      return .none
    case .picker(.presented(.selected(let urls))):
      return .task(
        operation: {
          guard let firstURL = urls.first else {
            return .parsingFailed
          }
          let csvString = try String(contentsOf: firstURL, encoding: .utf8)
          let records = try DataImporter.CSV.parseToRecord(csvString: csvString)
          return .delegate(.attemptImport(records))
        },
        catch: { error in
          logger.error("import failed \(error)")
          return .parsingFailed
        }
      )
    case .alert(.dismiss):
      state.alert = nil
      return .none
    case .importFromFileRowTapped:
      state.picker = DocumentPicker.State()
      return .none
    case .alert(.presented(.deleteAccountAlertConfirmed)):
      state.alert = nil
      return Effect(value: .delegate(.deleteAcountRequested))
        
    case .parsingFailed:
      state.showProgress = false
      // need show some alert here
      return .none
    case .picker:
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
  
  static var deleteAccount: Self {
    AlertState {
      TextState("DANGER ZONE")
    } actions: {
      ButtonState(role: .destructive, action: .send(.deleteAccountAlertConfirmed, animation: .default)) {
        TextState("Yes")
      }
    } message: {
      TextState("Are you sure you want to delete your account?")
    }
  }
}
