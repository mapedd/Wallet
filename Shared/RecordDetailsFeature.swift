//
//  RecordDetailsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import AppApi

struct RecordDetails: ReducerProtocol {
  struct State: Equatable {
    var record: MoneyRecord
    var categories: [Category] = []

    struct RenderableState: Hashable {
      @BindableState var amount: String
      @BindableState var title: String
      @BindableState var notes: String
      @BindableState var currencyCode: Currency.Code
      @BindableState var category: Category?
      @BindableState var recordType: MoneyRecord.RecordType
      @BindableState var date: Date
      var categories: [Category]
    }

    var renderableState: RenderableState {
      set {
        self.record.amount = Decimal(string: newValue.amount) ?? .zero
        self.record.title = newValue.title
        self.record.notes = newValue.notes
        self.record.currencyCode = newValue.currencyCode
        self.record.type = newValue.recordType
        self.record.date = newValue.date
        self.record.category = newValue.category
        self.categories = newValue.categories
      }
      get {
        .init(
          amount: record.amount.formatted(),
          title: record.title,
          notes: record.notes,
          currencyCode: record.currencyCode,
          category: record.category,
          recordType: record.type,
          date: record.date,
          categories: categories
        )
      }
    }

    static let preview = State(
      record: .init(
        id: .init(),
        date: .init(),
        title: "Shopping",
        notes: "Sample notes",
        type: .expense,
        amount: Decimal(123),
        currencyCode: "USD",
        category: nil
      )
    )
  }
  
  
  enum Action: BindableAction {
    case didAppear
    case loadedCategories([Category])
    case loadingCategoriesFailed(Swift.Error)
    case changeType(MoneyRecord.RecordType)
    case deleteRecordTapped
    case binding(BindingAction<State>)

    static func view(_ viewAction: RenderableAction) -> Self {
      switch viewAction {
      case .didAppear:
        return .didAppear
      case let .binding(action):
        return .binding(action.pullback(\.renderableState))

      case .deleteRecordTapped:
        return .deleteRecordTapped
      }
    }


    enum RenderableAction: BindableAction {
      case didAppear
      case binding(BindingAction<State.RenderableState>)
      case deleteRecordTapped
    }

  }
  
  @Dependency(\.apiClient) var apiClient
  
  var body: some ReducerProtocol<State, Action> {
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
        state.categories = localCategories
        return .none
      default:
        return .none
      }
    }
  }
}
