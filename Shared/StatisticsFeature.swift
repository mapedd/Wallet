//
//  StatisticsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct StatisticsState: Equatable {
  var records: IdentifiedArrayOf<RecordState> = []

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
  case showAll
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
  return .none
}
