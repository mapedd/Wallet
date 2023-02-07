//
//  RecordDetailsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import AppApi

public struct RecordDetails: ReducerProtocol {
  
  public init() {}

  public struct State: Equatable {
    
    public init(
      record: MoneyRecord,
      availableCategories: [MoneyRecord.Category] = []
    ) {
      self.record = record
      self.availableCategories = availableCategories
    }

    
    public var record: MoneyRecord
    public var availableCategories: [MoneyRecord.Category] = []

    public struct RenderableState: Hashable {
      public init(
        amount: String,
        title: String,
        notes: String,
        currencyCode: Currency.Code,
        assignedCategories: [MoneyRecord.Category],
        recordType: MoneyRecord.RecordType,
        date: Date,
        availableCategories: [MoneyRecord.Category]
      ) {
        self.amount = amount
        self.title = title
        self.notes = notes
        self.currencyCode = currencyCode
        self.assignedCategories = assignedCategories
        self.recordType = recordType
        self.date = date
        self.availableCategories = availableCategories
      }

      @BindableState public var amount: String
      @BindableState public var title: String
      @BindableState public var notes: String
      @BindableState public var currencyCode: Currency.Code
      @BindableState public var assignedCategories: [MoneyRecord.Category]
      @BindableState public var recordType: MoneyRecord.RecordType
      @BindableState public var date: Date
      public var availableCategories: [MoneyRecord.Category]
    }

    public var renderableState: RenderableState {
      set {
        self.record.amount = Decimal(string: newValue.amount) ?? .zero
        self.record.title = newValue.title
        self.record.notes = newValue.notes
        self.record.currencyCode = newValue.currencyCode
        self.record.type = newValue.recordType
        self.record.date = newValue.date
        self.record.categories = newValue.assignedCategories
        self.availableCategories = newValue.availableCategories
      }
      get {
        .init(
          amount: record.amount.formatted(),
          title: record.title,
          notes: record.notes,
          currencyCode: record.currencyCode,
          assignedCategories: record.categories,
          recordType: record.type,
          date: record.date,
          availableCategories: availableCategories
        )
      }
    }

    public static let preview = State(
      record: .init(
        id: .init(),
        date: .init(),
        title: "Shopping",
        notes: "Sample notes",
        type: .expense,
        amount: Decimal(123),
        currencyCode: "USD",
        categories: []
      )
    )
  }
  
  
  public enum Action: BindableAction {
    case didAppear
    case loadedCategories([MoneyRecord.Category])
    case loadingCategoriesFailed(Swift.Error)
    case changeType(MoneyRecord.RecordType)
    case deleteRecordTapped
    case binding(BindingAction<State>)
    case categoryTapped(MoneyRecord.Category)
    case hideDetails

    public static func view(_ viewAction: RenderableAction) -> Self {
      switch viewAction {
      case .didAppear:
        return .didAppear
      case let .binding(action):
        return .binding(action.pullback(\.renderableState))

      case .deleteRecordTapped:
        return .deleteRecordTapped
      case .categoryTapped(let category):
        return .categoryTapped(category)
      case .hideDetails:
        return .hideDetails
      }
    }


    public enum RenderableAction: BindableAction {
      case didAppear
      case binding(BindingAction<State.RenderableState>)
      case deleteRecordTapped
      case categoryTapped(MoneyRecord.Category)
      case hideDetails
    }

  }
  
  @Dependency(\.apiClient) var apiClient
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .didAppear:
         return  .task(
            operation: {
              let categories = try await apiClient.listCategories()
              let localCategeries = categories.map { $0.asLocaleCategory }
              return .loadedCategories(localCategeries)
            },
            catch: { error in
              return .loadingCategoriesFailed(error)
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
      default:
        return .none
      }
    }
  }
}
