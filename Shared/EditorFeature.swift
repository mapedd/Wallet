//
//  EditorFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import AppApi

extension AppApi.Currency.List {
  static var preview: AppApi.Currency.List {
    .init(
      code: "USD",
      name: "Dollar",
      namePlural: "Dollars",
      symbol: "$",
      symbolNative: "$"
    )
  }
}

struct Editor: ReducerProtocol {
  
  struct State: Equatable {
    @BindableState var text = "New Record title"
    @BindableState var amount = "0.00"
    @BindableState var currency: AppApi.Currency.List
    @BindableState var recordType = MoneyRecord.RecordType.expense
    @BindableState var category: Category? = nil
    var addButtonDisabled = true
    var categories: [Category] = []
    
    static let preview = Self.init(
      text: "Buying groceries",
      amount: "123.00",
      currency: .preview,
      recordType: .expense,
      category: nil,
      addButtonDisabled: false,
      categories: Category.previews
    )
    
  }
  
  
  
  enum Action:BindableAction {
    case binding(BindingAction<State>)
    case changeRecordType(MoneyRecord.RecordType)
    case addButtonTapped
    case categoryPicked(Category?)
  }
  
  
  var body: some ReducerProtocol<State,Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.$text):
        state.addButtonDisabled = State.addButtonDisabled(state)
        return .none
      case .binding(\.$amount):
        state.addButtonDisabled = State.addButtonDisabled(state)
        return .none
      case .addButtonTapped:
        return .none
      case let .changeRecordType(type):
        state.recordType = type
        return .none
      case let .categoryPicked(category):
        state.category = category
        return .none
      case .binding(_):
        return .none
      }
    }
  }
}

extension Editor.State {
  static func addButtonDisabled(_ state: Editor.State) -> Bool {
    state.text.isEmpty || Decimal(string: state.amount) == nil
  }
}
