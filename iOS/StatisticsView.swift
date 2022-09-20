//
//  StatisticsView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 07/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct StatisticsView: View {
  var store: Store<StatisticsState, StatisticsAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        HStack {
          Picker(
            selection: viewStore.binding(
              get: \.dateFilter,
              send: StatisticsAction.changeDateFilter
            ),
            content: {
              ForEach(StatisticsState.DateRange.allCases) { range in
                Text(range.stringValue)
                  .tag(StatisticsState.Filter.dateRange(range))
              }
            },
            label: {
              Text(viewStore.dateFilter.stringValue)
            }
          )
          .pickerStyle(MenuPickerStyle())

          Picker(
            "Filter",
            selection: viewStore.binding(
              get: \.filter,
              send: StatisticsAction.changeFilter
            )
          ) {
            Text("Expense")
              .tag(StatisticsState.Filter.expenseType(.expense))
            Text("Income")
              .tag(StatisticsState.Filter.expenseType(.income))
          }
          .pickerStyle(.segmented)
          Text(viewStore.formattedFilteredTotal)
        }
        .padding()

        List {
          ForEachStore(
            self.store.scope(
              state: \.filtered,
              action: StatisticsAction.recordAction(id:action:)
            )
          ) {
            RecordView(store: $0)
          }
        }

//        List(viewStore.filtered) { record in
//          RecordView(
//            store: .init(
//              initialState: record,
//              reducer: recordReducer,
//              environment: RecordEnvironment()
//            )
//          )
//        }
      }
    }
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
