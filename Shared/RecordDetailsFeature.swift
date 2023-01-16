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

    struct RenderableState: Hashable {
      @BindableState var amount: String
      @BindableState var title: String
      @BindableState var notes: String
      @BindableState var currencyCode: Currency.Code
      @BindableState var recordType: MoneyRecord.RecordType
      @BindableState var date: Date
    }

    var renderableState: RenderableState {
      set {
        self.record.amount = Decimal(string: newValue.amount) ?? .zero
        self.record.title = newValue.title
        self.record.notes = newValue.notes
        self.record.currencyCode = newValue.currencyCode
        self.record.type = newValue.recordType
        self.record.date = newValue.date
      }
      get {
        .init(
          amount: record.amount.formatted(),
          title: record.title,
          notes: record.notes,
          currencyCode: record.currencyCode,
          recordType: record.type,
          date: record.date
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
        currencyCode: "USD"
      )
    )
  }
  
  
  enum Action: BindableAction {

    case changeType(MoneyRecord.RecordType)
    case deleteRecordTapped
    case binding(BindingAction<State>)

    static func view(_ viewAction: RenderableAction) -> Self {
      switch viewAction {
      case let .binding(action):
        return .binding(action.pullback(\.renderableState))

      case .deleteRecordTapped:
        return .deleteRecordTapped
      }
    }


    enum RenderableAction: BindableAction {
      case binding(BindingAction<State.RenderableState>)
      case deleteRecordTapped
    }

  }
  
  var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Reduce { state, action in
      return .none
    }
  }
}
