//
//  EditorView.swift
//  Wallet (iOS)
//
//  Created by Tomasz Kuzma on 22/09/2022.
//

import SwiftUI
import ComposableArchitecture
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
      Text(viewStore.currency.name)
        .font(.title)
        .monospacedDigit()
      TextField(
        "Amount",
        text: viewStore.binding(\.$amount)
      )
      .font(.title)
      .monospacedDigit()
      .padding()
    }
  }

  func addButton(_ viewStore: ViewStore<Editor.State, Editor.Action>) -> some View {
    Button {
      viewStore.send(.addButtonTapped)
    } label: {
      Text("+")
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


  func imageView(
    record: MoneyRecord.RecordType
  ) -> some View {
    Image(nsImage: NSImage(systemSymbolName: record.name, accessibilityDescription: nil)!)
      .renderingMode(.template)
      .tag(record)
  }
}




extension MoneyRecord.RecordType {
  var color: NSColor {
    switch self {
    case .income:
      return .green
    case .expense:
      return .red
    }
  }
  var name: String {
    switch self {
    case .income:
      return "arrow.down.square.fill"
    case .expense:
      return "arrow.up.square.fill"
    }
  }
}

struct EditorView_Previews: PreviewProvider {
  static var previews: some View {
    EditorView(
      store: .init(
        initialState: .init(currency: .eur),
        reducer: Editor()
      )
    )
  }
}
