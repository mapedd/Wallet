//
//  Statistics.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 07/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct StatisticsState: Equatable {
  var records: IdentifiedArrayOf<MoneyRecord> = []

  static let preview = Self.init(records: [])
}

enum StatisticsAction: Equatable {

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

struct StatisticsView: View {
  var store: Store<StatisticsState, StatisticsAction>
  var body: some View {
    Text("hello statistics")
  }
}

struct StatisticsView_Previews: PreviewProvider {
  static var previews: some View {
    StatisticsView(store: .init(
      initialState: .preview,
      reducer: statisticsReducer,
      environment: StatisticsEnvironment()
    )
    )
  }
}
