//
//  EditorView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct EditorView: View {
  var store: Store<EditorState, EditorAction>
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

  func categoryPicker(_ viewStore: ViewStore<EditorState, EditorAction>) -> some View {
    Picker(
      selection: viewStore.binding(\.$category),
      content: {
        ForEach(viewStore.categories) { category in
          Text(category.name)
            .tag(category)
        }
      },
      label: {
        Text(viewStore.category?.name ?? "Pick category")
      }
    )
    .pickerStyle(MenuPickerStyle())

  }

  func amountTextField(_ viewStore: ViewStore<EditorState, EditorAction>) -> some View {
    HStack(spacing: 0) {
      Text(viewStore.currencySymbol)
        .font(.title)
        .monospacedDigit()
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

  func addButton(_ viewStore: ViewStore<EditorState, EditorAction>) -> some View {
    Button {
      viewStore.send(.addButtonTapped)
    } label: {
      Text("Add")
        .font(.title)
        .bold()
    }.disabled(viewStore.addButtonDisabled)
  }

  func recordTextField(_ viewStore: ViewStore<EditorState, EditorAction>) -> some View {
    TextField(
      "Untitled Todo",
      text: viewStore.binding(\.$text)
    )
  }

  func recordTypePicker(_ viewStore: ViewStore<EditorState, EditorAction>) -> some View {
    Picker(
      "Tab",
      selection: viewStore.binding(
        get: \.recordType,
        send: EditorAction.changeRecordType
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
        reducer: editorReducer,
        environment: .init()
      )
    )
    .padding(40)
  }
}
