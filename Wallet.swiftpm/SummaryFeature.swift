//
//  SummaryFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct SummaryViewState: Equatable {
  var total = Decimal.zero
}

enum SummaryViewAction {
  case showSummaryButtonTapped
  case hideSummary
}

struct SummaryViewEnvironment {}

let summaryReducer = Reducer
<
  SummaryViewState,
  SummaryViewAction,
  SummaryViewEnvironment
> { state, action, _ in
  switch action {
  case .showSummaryButtonTapped:
    return .none
  case .hideSummary:
    return .none
  }
}
