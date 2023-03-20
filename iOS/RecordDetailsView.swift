//
//  RecordDetailsView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 10/09/2022.
//

import SwiftUI
import ComposableArchitecture
import AppApi
import WalletCore

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
        category(viewStore)
        deleteSection(viewStore)
      }
      .task{
        viewStore.send(.task)
      }
      .navigationTitle(
        Text(viewStore.record.date.formatted())
      )
      .navigationBarTitleDisplayMode(.inline)
      .navigationViewStyle(.stack)
      .alert(
        store: self.store.scope(state: \.alert, action: RecordDetails.Action.alert)
      )
    }
  }
  
  func type(_ viewStore: RecordDetailsViewStore) -> some View {
    Picker(
      "Type",
      selection: viewStore.binding(\.$record.type)
//      selection: viewStore.binding(\.$item.name)
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
      LabeledContent("Title") {
        TextField(
          "Title",
          text: viewStore.binding(\.$record.title),
          prompt: Text("Title")
        )
      }
      TextEditor(text: viewStore.binding(\.$record.notes))
    }
  }

  func amount(_ viewStore: RecordDetailsViewStore) -> some View {
    Section {
      LabeledContent {
        TextField(
          "Amount",
          text: viewStore.binding(
            get: {
              $0.formattedAmount
            },
            send: {
              .setAmount($0)
            }
          )
        )
      } label: {
        Text("Amount")
      }

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



  func category(_ viewStore: RecordDetailsViewStore) -> some View {
    Section {
      MultiPicker(
        label: "Categories",
        options: viewStore.availableCategories,
        pickedValues: viewStore.record.categories,
        itemTapped: { category in
          viewStore.send(.categoryTapped(category))
        }
      )
    }
  }

  func deleteSection(_ viewStore: RecordDetailsViewStore) -> some View {
    Section {
      Button("Delete record") {
        viewStore.send(.deleteRecordTapped)
      }
      .tint(.red)
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

extension MoneyRecord.Category : Readable {
  var readableDescription: String {
    name
  }
}
