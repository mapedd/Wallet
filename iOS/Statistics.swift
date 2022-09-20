//
//  Statistics.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 07/09/2022.
//

import SwiftUI
import ComposableArchitecture

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
