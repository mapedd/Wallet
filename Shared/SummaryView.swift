//
//  SummaryView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 05/09/2022.
//

import SwiftUI
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


struct SummaryView: View {
  var store: Store<SummaryViewState, SummaryViewAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack {
        HStack {
          Text("Total")
            .font(.title)
            .bold()
          Text(formatter.string(for:viewStore.total) ?? "")
            .font(.title)
            .monospacedDigit()
        }
        Spacer()
        Button(
          action: {viewStore.send(.showSummaryButtonTapped)},
          label: {
            HStack(spacing: 0) {
              Image(systemName: "brain.head.profile")
              Image(systemName: "chevron.forward")
            }
          }
        )
        .sheet(
          isPresented: viewStore.binding(
            get: \.showStatistics,
            send: { $0 ? .showSummaryButtonTapped : .hideSummary }
          )
        ) {
          IfLetStore(
            self.store.scope(
              state: \.statistics,
              action: SummaryViewAction.statisticsAction
            )
          ) {
            StatisticsView(store: $0)
          }
        }
      }
      .padding()
    }
  }
}


struct SummaryView_Previews: PreviewProvider {
  static var previews: some View {
    SummaryView(
      store: .init(
        initialState: .init(),
        reducer: summaryReducer,
        environment: .init()
      )
    )
  }
}
