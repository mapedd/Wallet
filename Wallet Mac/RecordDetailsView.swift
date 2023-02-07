//
//  RecordDetailsView.swift
//  Wallet Mac
//
//  Created by Tomasz Kuzma on 07/02/2023.
//

import Foundation

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
        type(viewStore)
        title(viewStore)
        amount(viewStore)
        currency(viewStore)
        deleteSection(viewStore)
      }
      .onAppear{
        viewStore.send(.didAppear)
      }
      .navigationTitle(
        Text(viewStore.date.formatted())
      )
    }
  }

  func type(_ viewStore: ViewStore<RecordDetails.State.RenderableState, RecordDetails.Action.RenderableAction>) -> some View {
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

  func title(_ viewStore: ViewStore<RecordDetails.State.RenderableState, RecordDetails.Action.RenderableAction>) -> some View {
    Section {
      TextField(
        "Title",
        text: viewStore.binding(\.$title),
        prompt: Text("Title")
      )
      TextEditor(text: viewStore.binding(\.$notes))
    }
  }

  func amount(_ viewStore: ViewStore<RecordDetails.State.RenderableState, RecordDetails.Action.RenderableAction>) -> some View {
    Section {
      TextField(
        "Amount",
        text: viewStore.binding(\.$amount)
      )
    }
  }

  func currency(_ viewStore: ViewStore<RecordDetails.State.RenderableState, RecordDetails.Action.RenderableAction>) -> some View {
    Section {
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
    }
  }


  func deleteSection(_ viewStore: ViewStore<RecordDetails.State.RenderableState, RecordDetails.Action.RenderableAction>) -> some View {
    Section {
      HStack {
        Button("Delete record") {
          viewStore.send(.deleteRecordTapped)
        }
        Spacer()
        Button("OK") {
          viewStore.send(.hideDetails)
        }
      }
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
