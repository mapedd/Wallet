//
//  RecordListView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct RecordView: View {
    var store: Store<RecordState, RecordAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Text(viewStore.record.formattedCopy)
                    .foregroundColor(viewStore.record.type == .income ? .green : .red)
                Button("Category",
                       action: {
                  viewStore.send(.showCategoryPickerTapped)
                })
            }
            .onTapGesture {
              viewStore.send(.setSheet(isPresented: true))
            }
            .sheet(
              isPresented: viewStore.binding(
                get: \.isSheetPresented,
                send: RecordAction.setSheet(isPresented:)
              )
            ) {
              IfLetStore(
                self.store.scope(
                  state: \.details,
                  action: RecordAction.detailsAction
                )
              ) {
                RecordDetailsView(store: $0)
              }
            }
        }
    }
}


struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(
            store: .init(
                initialState: .init(
                    record: .init(
                        id: .init(),
                        date: .init(),
                        title: "Record",
                        type: .expense,
                        amount: Decimal(123),
                        currency: .usd
                    )
                ),
                reducer: combinedRecordReducer,
                environment: RecordEnvironment()
            )
        )
    }
}
