//
//  RecordDetails.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 10/09/2022.
//

import SwiftUI
import ComposableArchitecture
import AppApi

struct RecordDetailsView: View {
  var store: StoreOf<RecordDetails>

  var body: some View {
    WithViewStore(
      self.store,
      observe: \.renderableState,
      send: RecordDetails.Action.view
    ) { viewStore in
      Form {
        Section {
          
          Picker(
            "Type",
            selection: viewStore.binding(\.$recordType)
          ) {
            Text("Expense")
              .tag(MoneyRecord.RecordType.expense)
              .tint(.red)

            Text("Income")
              .tag(MoneyRecord.RecordType.income)
              .tint(.green)
          }
          .pickerStyle(.segmented)
        }
        
        Section {
          LabeledContent("Title") {
            TextField(
              "Title",
              text: viewStore.binding(\.$title),
              prompt: Text("Title")
            )
          }
          TextEditor(text: viewStore.binding(\.$notes))
        }
        
        Section {
          HStack {
            Picker(
              "Currency",
              selection: viewStore.binding(\.$currencyCode)
            ) {
              ForEach(Currency.List.examples) { currency in
                Text(currency.symbol)
                  .tag(currency)
              }
            }
            .pickerStyle(.menu)
            Spacer()
            TextField(
              "Amount",
              text: viewStore.binding(\.$amount)
            )
          }
        }
        
        
        Section {
          Button("Delete record") {
            viewStore.send(.deleteRecordTapped)
          }
          .tint(.red)
        }
      }
      .navigationTitle(
        Text(viewStore.date.formatted())
      )
      .navigationBarTitleDisplayMode(.inline)
      .navigationViewStyle(.stack)
    }
  }

}

struct RecordDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    RecordDetailsView(
      store: Store(
        initialState: .init(
          record: .preview
        ),
        reducer: RecordDetails()
      )
    )
  }
}
