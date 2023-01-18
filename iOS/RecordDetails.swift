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
        type(viewStore)
        title(viewStore)
        amount(viewStore)
        currency(viewStore)
        category(viewStore)
        deleteSection(viewStore)
      }
      .onAppear{
        viewStore.send(.didAppear)
      }
      .navigationTitle(
        Text(viewStore.date.formatted())
      )
      .navigationBarTitleDisplayMode(.inline)
      .navigationViewStyle(.stack)
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
      LabeledContent("Title") {
        TextField(
          "Title",
          text: viewStore.binding(\.$title),
          prompt: Text("Title")
        )
      }
      TextEditor(text: viewStore.binding(\.$notes))
    }
  }
  
  func amount(_ viewStore: ViewStore<RecordDetails.State.RenderableState, RecordDetails.Action.RenderableAction>) -> some View {
    Section {
      LabeledContent {
        TextField(
          "Amount",
          text: viewStore.binding(\.$amount)
        )
      } label: {
        Text("Amount")
      }

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
  
  
  
  func category(_ viewStore: ViewStore<RecordDetails.State.RenderableState, RecordDetails.Action.RenderableAction>) -> some View {
    Section {
      MultiPicker(
        label: "Categories",
        options: viewStore.availableCategories,
        pickedValues: viewStore.assignedCategories,
        itemTapped: { category in
          viewStore.send(.categoryTapped(category))
        }
      )
    }
  }
  
  func deleteSection(_ viewStore: ViewStore<RecordDetails.State.RenderableState, RecordDetails.Action.RenderableAction>) -> some View {
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

extension Category : Readable {
  var readableDescription: String {
    name
  }
}
