//
//  SummaryFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct SummaryViewState: Equatable {
  var statistics: StatisticsState?
  var showStatistics: Bool {
    statistics != nil
  }
  var total = Decimal.zero
}

enum SummaryViewAction: Equatable {
  case showSummaryButtonTapped
  case hideSummary
  case statisticsAction(StatisticsAction)
}

struct SummaryViewEnvironment {}

let summaryReducer = statisticsReducer
  .optional()
  .pullback(
    state: \.statistics,
    action: /SummaryViewAction.statisticsAction,
    environment:{ _ in  StatisticsEnvironment() }
  )
  .combined(with: summaryViewReducer)

let summaryViewReducer = Reducer
<
  SummaryViewState,
  SummaryViewAction,
  SummaryViewEnvironment
> { state, action, _ in
  switch action {
  case .showSummaryButtonTapped:
    state.statistics = .init(records: [])
    return .none
  case .hideSummary:
    state.statistics = nil
    return .none
  default:
    return .none
  }
}
