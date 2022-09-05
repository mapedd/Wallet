//
//  SummaryView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 05/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct SummaryViewState: Equatable {
    var total = Decimal.zero
}

enum SummaryViewAction: Equatable {
     case showSummaryButtonTapped
}

struct SummaryViewEnvironment {}

let summaryViewReducer = Reducer
<
SummaryViewState,
SummaryViewAction,
SummaryViewEnvironment
> { state, action, _ in
        .none
}


struct SummaryView: View {
    var store: Store<SummaryViewState, SummaryViewAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                VStack {
                    Text("Total")
                    Text(formatter.string(for:viewStore.total) ?? "")
                }
                Button(
                    action: {viewStore.send(.showSummaryButtonTapped)},
                    label: {}
                )
            }
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(
            store: .init(
                initialState: .init(),
                reducer: summaryViewReducer,
                environment: .init()
            )
        )
    }
}
