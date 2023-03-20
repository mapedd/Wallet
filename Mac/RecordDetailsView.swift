//
//  RecordDetailsView.swift
//  Wallet Mac
//
//  Created by Tomasz Kuzma on 07/02/2023.
//

import Foundation
import WalletCore
import SwiftUI
import ComposableArchitecture
import AppApi

typealias RecordDetailsViewStore = ViewStore<RecordDetails.State, RecordDetails.Action>

struct RecordDetailsView: View {
  var store: StoreOf<RecordDetails>

  var body: some View {
    WithViewStore(
      self.store,
      observe: { $0 }
    ) { viewStore in
      Form {
        type(viewStore)
        title(viewStore)
        amount(viewStore)
        currency(viewStore)
      }
      .onAppear{
        viewStore.send(.task)
      }
      .navigationTitle(
        Text(viewStore.record.date.formatted())
      )
    }
  }

  func type(_ viewStore: RecordDetailsViewStore) -> some View {
    Picker(
      "Type",
      selection: viewStore.binding(\.$record.type)
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

  func title(_ viewStore: RecordDetailsViewStore) -> some View {
    Section {
      TextField(
        "Title",
        text: viewStore.binding(\.$record.title),
        prompt: Text("Title")
      )
      TextEditor(text: viewStore.binding(\.$record.notes))
    }
  }

  func amount(_ viewStore: RecordDetailsViewStore) -> some View {
    Section {
      TextField(
        "Amount",
        text: .constant("123")
      )
    }
  }

  func currency(_ viewStore: RecordDetailsViewStore) -> some View {
    Section {
      Picker(
        "Currency",
        selection: viewStore.binding(\.$record.currencyCode)
      ) {
        ForEach(Currency.List.examples) { currency in
          Text(currency.symbol)
            .tag(currency)
        }
      }
      .pickerStyle(.menu)
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
