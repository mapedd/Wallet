//
//  EditorFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct EditorState: Equatable {
  @BindableState var text = "New Record title"
  @BindableState var amount = "0.00"
  var currencySymbol = "$"
  @BindableState var recordType = MoneyRecord.RecordType.expense
  @BindableState var category: Category? = nil
  var addButtonDisabled = true
  var categories: [Category] = []

  static let preview = Self.init(
    text: "Buying groceries",
    amount: "123.00",
    currencySymbol: "€",
    recordType: .expense,
    category: .init(name: "Food", id: .init()),
    addButtonDisabled: false,
    categories: Category.previews
  )

}



enum EditorAction:BindableAction {
  case binding(BindingAction<EditorState>)
  case changeRecordType(MoneyRecord.RecordType)
  case addButtonTapped
}

struct EditorEnvironment {

}

extension EditorState {
  static func addButtonDisabled(_ state: EditorState) -> Bool {
    state.text.isEmpty || Decimal(string: state.amount) == nil
  }
}

let editorReducer = Reducer<EditorState, EditorAction, EditorEnvironment> { state, action, _ in
  switch action {
  case .binding(\.$text):
    state.addButtonDisabled = EditorState.addButtonDisabled(state)
    return .none
  case .binding(\.$amount):
    state.addButtonDisabled = EditorState.addButtonDisabled(state)
    return .none
  case .addButtonTapped:
    return .none
  case let .changeRecordType(type):
    state.recordType = type
    return .none
  case .binding(_):
    return .none
  }
}
  .binding()
  .debug()
