//
//  RecordDetails.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 10/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct RecordDetailsState: Equatable {
  var record: MoneyRecord

  struct RenderableState: Equatable {
    @BindableState var amount: String
    @BindableState var title: String
    @BindableState var date: Date
  }

  var renderableState: RenderableState {
    set {
      self.record.amount = Decimal(string: newValue.amount) ?? .zero
      self.record.title = newValue.title
      self.record.date = newValue.date
    }
    get {
      .init(
        amount: record.amount.formatted(),
        title: record.title,
        date: record.date
      )
    }
  }



  static let preview = RecordDetailsState(
    record: .init(
      id: .init(),
      date: .init(),
      title: "Shopping",
      type: .expense,
      amount: Decimal(123),
      currency: .usd
    )
  )
}


enum RecordDetailsAction: BindableAction {

  case binding(BindingAction<RecordDetailsState>)

  static func view(_ viewAction: RenderableAction) -> Self {
    switch viewAction {
    case let .binding(action):
      return .binding(action.pullback(\.renderableState))
    }
  }


  enum RenderableAction: BindableAction {
    case binding(BindingAction<RecordDetailsState.RenderableState>)
  }

}

struct RecordDetailsEnvironment {

}

let recordDetailsReducer = Reducer
<
  RecordDetailsState,
  RecordDetailsAction,
  RecordDetailsEnvironment
>
{ state, action , _ in
  return .none
}
.binding()

struct RecordDetailsView: View {
  var store: Store<RecordDetailsState, RecordDetailsAction>

  var body: some View {
    WithViewStore(
      self.store, observe: \.renderableState, send: RecordDetailsAction.view
    ) { viewStore in
      NavigationView {
        ScrollView {
          VStack {
            amount(viewStore)
            Text(viewStore.date.formatted())
          }
        }
      }
    }
  }

  func amount(_ viewStore: ViewStore<RecordDetailsState.RenderableState, RecordDetailsAction.RenderableAction>) -> some View {
    HStack(spacing: 0) {
      Text(viewStore.title)
        .font(.title)
        .monospacedDigit()
      TextField(
        "Amount",
        text: viewStore.binding(\.$title)
      )
      .font(.title)
      .monospacedDigit()
      .keyboardType(.decimalPad)
      .padding()
    }
  }
}

struct RecordDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    RecordDetailsView(
      store: .init(
        initialState: .preview,
        reducer: recordDetailsReducer,
        environment: RecordDetailsEnvironment()
      )
    )
  }
}
