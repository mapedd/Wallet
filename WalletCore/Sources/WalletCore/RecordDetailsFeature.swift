//
//  RecordDetailsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import AppApi
import WalletCoreDataModel

public struct RecordDetails: ReducerProtocol {
  
  public init() {}

  public struct State: Equatable, Identifiable {
    
    public init(
      record: MoneyRecord,
      availableCategories: [MoneyRecord.Category] = [],
      alert: AlertState<Action.Alert>? = nil
    ) {
      self.record = record
      self.availableCategories = availableCategories
      self.alert = alert
    }

    public var id: UUID {
      record.id
    }
    @BindingState public var record: MoneyRecord
    public var availableCategories: [MoneyRecord.Category] = []
    public var alert: AlertState<Action.Alert>?
    
    
    public var formattedAmount: String {
      record.amount.formatted()
    }
  }
  
  
  public enum Action: BindableAction, Equatable{
    case task
    case loadedCategories([MoneyRecord.Category])
    case loadingCategoriesFailed(String)
    case deleteRecordTapped
    case binding(BindingAction<State>)
    case categoryTapped(MoneyRecord.Category)
    case setAmount(String)
    case alert(PresentationAction<Alert>)
    
    public enum Alert: Equatable {
      case deleteConfirm
    }
    
  }
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.dismiss) var dismiss
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Reduce<State, Action> { state, action in
      switch action {
      case .task:
         return  .task(
            operation: {
              let categories = try await apiClient.listCategories()
              let localCategeries = categories.map { $0.asLocaleCategory }
              return .loadedCategories(localCategeries)
            },
            catch: { error in
              return .loadingCategoriesFailed(error.localizedDescription)
            }
          )
      case .loadedCategories(let localCategories):
        state.availableCategories = localCategories
        return .none
      case .categoryTapped(let category):
        let contains = state.record.categories.contains(where: {
          $0.id == category.id
        })
        
        if contains {
          state.record.categories.removeAll { inside in
            inside.id == category.id
          }
        } else {
          state.record.categories.append(category)
        }
        return .none
      case .loadingCategoriesFailed(_):
        return .none
      case .deleteRecordTapped:
        state.alert = .delete(record: state.record)
        return .none
      case .binding:
        return .none
      case .setAmount(let amount):
        state.record.amount =  Decimal(string: amount) ?? .zero
        return .none
      case .alert:
        return .none
      }
    }
    .ifLet(\.alert, action: /Action.alert)
  }
}

extension AlertState where Action == RecordDetails.Action.Alert {
  static func delete(record: MoneyRecord) -> Self {
    AlertState {
      TextState(#"Delete "\#(record.title)""#)
    } actions: {
      ButtonState(role: .destructive, action: .send(.deleteConfirm, animation: .default)) {
        TextState("Delete")
      }
    } message: {
      TextState("Are you sure you want to delete this item?")
    }
  }
}
