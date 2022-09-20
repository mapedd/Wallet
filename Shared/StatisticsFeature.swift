//
//  StatisticsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct StatisticsState: Equatable {
  var records: IdentifiedArrayOf<MoneyRecord> = []

  static let preview = Self.init(records: [])
}

enum StatisticsAction: Equatable {
  case showAll
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
