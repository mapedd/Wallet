//
//  StatisticsView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 07/09/2022.
//

import SwiftUI
import ComposableArchitecture
import WalletCore

struct StatisticsView: View {
  var store: StoreOf<Statistics>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        HStack {
          Picker(
            selection: viewStore.binding(
              get: \.dateFilter,
              send: Statistics.Action.changeDateFilter
            ),
            content: {
              ForEach(Statistics.State.DateRange.allCases) { range in
                Text(range.stringValue)
                  .tag(Statistics.State.Filter.dateRange(range))
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
              send: Statistics.Action.changeFilter
            )
          ) {
            Text("Expense")
              .tag(Statistics.State.Filter.expenseType(.expense))
            Text("Income")
              .tag(Statistics.State.Filter.expenseType(.income))
          }
          .pickerStyle(.segmented)
          Text(viewStore.formattedFilteredTotal)
        }
        .padding()
        
        List {
          ForEach(viewStore.filtered) {
            RecordView(record: $0)
          }
        }
      }
    }
  }
}

struct StatisticsView_Previews: PreviewProvider {
  static var previews: some View {
    StatisticsView(
      store: .init(
        initialState: .preview,
        reducer: Statistics()
      )
    )
  }
}
