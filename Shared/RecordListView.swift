//
//  RecordListView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct RecordListState: Equatable {
    var records: IdentifiedArrayOf<MoneyRecord> = []
}

enum RecordListAction: Equatable {

}

struct RecordListEnvironment {

}


let recordListReducer = Reducer<RecordListState, RecordListAction, RecordListEnvironment> { state, action, _ in
        .none
}

struct RecordListView: View {
    var store: Store<RecordListState, RecordListAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            List(viewStore.records) {
                Text("\($0.title)")
                    .foregroundColor($0.type == .income ? .green : .red)
            }
        }
    }
}

struct RecordListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordListView(
            store: .init(
                initialState: .init(records: [
                    .init(
                        id: .init(),
                        date: .init(),
                        title: "Record 0",
                        type: .income,
                        amount: Decimal(123),
                        currency: .usd
                    ),
                    .init(
                        id: .init(),
                        date: .init(),
                        title: "Record 1",
                        type: .expense,
                        amount: Decimal(233),
                        currency: .usd
                    )
                ]),
                reducer: recordListReducer,
                environment: RecordListEnvironment()
            )
        )
    }
}
