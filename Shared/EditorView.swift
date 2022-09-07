//
//  EditorView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct EditorState: Equatable {
  @BindableState var text = "New Record"
  @BindableState var amount = "0.00"
  var currencySymbol = "$"
  @BindableState var recordType = MoneyRecord.RecordType.expense
  var addButtonDisabled = false

  static let preview = Self.init(
    text: "Buying groceries",
    amount: "123.00",
    currencySymbol: "€",
    recordType: .expense,
    addButtonDisabled: false
  )

}

extension MoneyRecord.RecordType {
  var color: UIColor {
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

enum EditorAction:BindableAction, Equatable {
  case binding(BindingAction<EditorState>)
  case changeRecordType(MoneyRecord.RecordType)
  case addButtonTapped
}

struct EditorEnvironment {

}

let editorReducer = Reducer<EditorState, EditorAction, EditorEnvironment> { state, action, _ in
  switch action {
  case .binding(\.$text):
    state.addButtonDisabled = state.text.isEmpty && Decimal(string: state.amount) != nil
    return .none
  case .addButtonTapped:
    return .none
  case let .changeRecordType(type):
    state.recordType = type
    return .none
  case .binding(_):
    return .none
  }
}
  .binding()

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
        recordTypePicker(viewStore)
      }
    }
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
