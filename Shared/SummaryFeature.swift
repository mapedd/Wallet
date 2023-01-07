//
//  SummaryFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct Summary: ReducerProtocol {
  
  struct State: Equatable {
    var total = Decimal.zero
    var currency: Currency
  }
  
  enum Action {
    case showSummaryButtonTapped
    case hideSummary
  }
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    
    switch action {
    case .showSummaryButtonTapped:
      return .none
    case .hideSummary:
      return .none
    }
  }
  
}
