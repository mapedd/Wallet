//
//  SummaryView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 05/09/2022.
//

import SwiftUI
import ComposableArchitecture

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
