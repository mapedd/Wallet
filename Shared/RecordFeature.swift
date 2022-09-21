//
//  RecordFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct RecordState: Equatable, Identifiable {
  var record: MoneyRecord
  var details: RecordDetailsState?
  var id: UUID {
    record.id
  }
  var isSheetPresented: Bool {
    details != nil
  }

  static var sample: [RecordState] = [
    RecordState(
      record: .init(
        id: .init(),
        date: .init(),
        title: "sample expense today",
        type: .expense,
        amount: Decimal(123),
        currency: .eur,
        category: .init(name: "Food", id: .init())
      )
    ),
    RecordState(
      record: .init(
        id: .init(),
        date: .init(),
        title: "sample income today",
        type: .income,
        amount: Decimal(222),
        currency: .eur
      )
    ),
    RecordState(
      record: .init(
        id: .init(),
        date: .init().addingTimeInterval(-60 * 60 * 24 * 3),
        title: "sample income 3 days ago",
        type: .income,
        amount: Decimal(9.99),
        currency: .eur,
        category: .init(name: "Entertainment", id: .init())
      )
    ),
    RecordState(
      record: .init(
        id: .init(),
        date: .init().addingTimeInterval(-60 * 60 * 24 * 30),
        title: "sample income month ago",
        type: .income,
        amount: Decimal(44.2),
        currency: .eur
      )
    )
  ]
}

enum RecordAction {
  case showCategoryPickerTapped
  case setSheet(isPresented:Bool)
  case detailsAction(RecordDetailsAction)
}

struct RecordEnvironment {

}


let recordReducer = Reducer<
  RecordState,
  RecordAction,
  RecordEnvironment>
{ state, action, _ in
  switch action {
  case .setSheet(isPresented: true):
    state.details = .init(record: state.record)
    return .none
  case .setSheet(isPresented: false):
    if let updatedRecord = state.details?.record {
      state.record = updatedRecord
    }
    state.details = nil
    return .none

  case .detailsAction(let recordDetailsAction) :
    if case .deleteRecordTapped = recordDetailsAction {
      state.details = nil
    }
    return .none
  default:
    return .none
  }
}

let combinedRecordReducer = recordDetailsReducer
  .optional()
  .pullback(
    state: \.details,
    action: /RecordAction.detailsAction,
    environment: { _ in RecordDetailsEnvironment() }
  )
  .combined(with: recordReducer)
