//
//  RecordDetailsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct RecordDetailsState: Equatable {
  var record: MoneyRecord

  struct RenderableState: Equatable {
    @BindableState var amount: String
    @BindableState var title: String
    @BindableState var date: Date
  }

  var renderableState: RenderableState {
    set {
      self.record.amount = Decimal(string: newValue.amount) ?? .zero
      self.record.title = newValue.title
      self.record.date = newValue.date
    }
    get {
      .init(
        amount: record.amount.formatted(),
        title: record.title,
        date: record.date
      )
    }
  }

  static let preview = RecordDetailsState(
    record: .init(
      id: .init(),
      date: .init(),
      title: "Shopping",
      type: .expense,
      amount: Decimal(123),
      currency: .usd
    )
  )
}


enum RecordDetailsAction: BindableAction {

  case deleteRecordTapped
  case binding(BindingAction<RecordDetailsState>)

  static func view(_ viewAction: RenderableAction) -> Self {
    switch viewAction {
    case let .binding(action):
      return .binding(action.pullback(\.renderableState))

    case .deleteRecordTapped:
      return .deleteRecordTapped
    }
  }


  enum RenderableAction: BindableAction {
    case binding(BindingAction<RecordDetailsState.RenderableState>)
    case deleteRecordTapped
  }

}

struct RecordDetailsEnvironment {

}

let recordDetailsReducer = Reducer
<
  RecordDetailsState,
  RecordDetailsAction,
  RecordDetailsEnvironment
>
{ state, action , _ in
  return .none
}
.binding()
