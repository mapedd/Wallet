//
//  EditorView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture
import AppApi
import WalletCore

struct EditorView: View {
  var store: StoreOf<Editor>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 4) {
        HStack {
          amountTextField(viewStore)
          addButton(viewStore)
        }
        recordTextField(viewStore)
        HStack {
          recordTypePicker(viewStore)
          categoryPicker(viewStore)
        }

      }
    }
  }

  func categoryPicker(_ viewStore: ViewStore<Editor.State, Editor.Action>) -> some View {

    Picker(
      "Category",
      selection: viewStore.binding(\.$category)
    ) {
      ForEach(viewStore.categories) { category in
        Text(category.name)
          .tag(Optional(category)) // optionality must be the same
      }
    }
    .pickerStyle(.menu)
  }

  func amountTextField(_ viewStore: ViewStore<Editor.State, Editor.Action>) -> some View {
    HStack(spacing: 0) {
      Picker("Currency", selection: viewStore.binding(\.$currency)) {
        ForEach(Currency.List.examples) { currency in
          Text(currency.symbol)
            .tag(currency)
        }
      }
      TextField(
        "Amount",
        text: viewStore.binding(\.$amount)
      )
      .font(.title)
      .monospacedDigit()
      .keyboardType(.decimalPad)
      .padding()
    }
  }

  func addButton(_ viewStore: ViewStore<Editor.State, Editor.Action>) -> some View {
    Button {
      viewStore.send(.addButtonTapped)
    } label: {
      Text("Add")
        .font(.title)
        .bold()
    }.disabled(viewStore.addButtonDisabled)
  }

  func recordTextField(_ viewStore: ViewStore<Editor.State, Editor.Action>) -> some View {
    TextField(
      "Untitled Todo",
      text: viewStore.binding(\.$text)
    )
  }

  func recordTypePicker(_ viewStore: ViewStore<Editor.State, Editor.Action>) -> some View {
    Picker(
      "Tab",
      selection: viewStore.binding(
        get: \.recordType,
        send: Editor.Action.changeRecordType
      )
    ) {
      imageView(record: .expense)
      imageView(record: .income)
    }
    .pickerStyle(.segmented)
  }

  func config(color: UIColor) -> UIImage.SymbolConfiguration {
    UIImage.SymbolConfiguration(paletteColors: [color])
  }

  func imageView(
    record: MoneyRecord.RecordType
  ) -> some View {
    Image(uiImage: UIImage(systemName: record.name, withConfiguration:config(color: record.color))!)
      .renderingMode(.template)
      .foregroundColor(Color(record.color))
      .tag(record)
  }
}

struct EditorView_Previews: PreviewProvider {
  static var previews: some View {
    EditorView(
      store: .init(
        initialState: .preview,
        reducer: Editor()
      )
    )
    .padding(40)
  }
}
