//
//  SummaryFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

public struct Summary: ReducerProtocol {

  public init() {}
  
  public struct State: Equatable {
    
    public init(
      total: Decimal = Decimal.zero,
      baseCurrencyCode: String
    ) {
      self.total = total
      self.baseCurrencyCode = baseCurrencyCode
    }


    public var total = Decimal.zero
    public var baseCurrencyCode: String
  }
  
  public enum Action {
    case showSummaryButtonTapped
    case hideSummary
  }
  
  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    
    switch action {
    case .showSummaryButtonTapped:
      return .none
    case .hideSummary:
      return .none
    }
  }
  
}
