//
//  StatisticsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct StatisticsState: Equatable {
  enum Filter: Hashable {
    case expenseType(MoneyRecord.RecordType)
  }
  var records: IdentifiedArrayOf<RecordState> = []
  var filter: Filter = .expenseType(.expense)
  var filteredTotal: Decimal  {
    let sum = filtered.reduce(Decimal.zero, { partialResult, recordState in
      if recordState.record.type == .expense {
        return partialResult - recordState.record.amount
      } else if recordState.record.type == .income {
        return partialResult + recordState.record.amount
      } else {
        fatalError("not handled record type")
      }
    })
    return sum
  }

  var filtered: IdentifiedArrayOf<RecordState> {
    records.filter { recordState in
      if case .expenseType(let type) = filter {
        return recordState.record.type == type
      } else {
        return true
      }
    }
  }

  static let preview = Self.init(records: [
    RecordState(
      record: .init(
        id: .init(),
        date: .init(),
        title: "sample expense",
        type: .expense,
        amount: Decimal(123),
        currency: .eur
      )
    ),
    RecordState(
      record: .init(
        id: .init(),
        date: .init(),
        title: "sample income",
        type: .income,
        amount: Decimal(222),
        currency: .eur
      )
    ),
  ])
}

enum StatisticsAction {
  case datePickerTapped
  case changeFilter(StatisticsState.Filter)
  case recordAction(id: RecordState.ID, action: RecordAction)
}

struct StatisticsEnvironment {

}

let statisticsReducer = Reducer
<
  StatisticsState,
  StatisticsAction,
  StatisticsEnvironment
> { state, action, _ in
  switch action {

  case .datePickerTapped:
    return .none
  case .changeFilter(let filter):
    state.filter = filter
    return .none
  case .recordAction(id: let id, action: let action):
    return .none
  }
  return .none
}
