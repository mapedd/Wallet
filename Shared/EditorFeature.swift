//
//  EditorFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct EditorState: Equatable {
  @BindableState var text = "New Record"
  @BindableState var amount = "0.00"
  var currencySymbol = "$"
  @BindableState var recordType = MoneyRecord.RecordType.expense
  var addButtonDisabled = true

  static let preview = Self.init(
    text: "Buying groceries",
    amount: "123.00",
    currencySymbol: "€",
    recordType: .expense,
    addButtonDisabled: false
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
