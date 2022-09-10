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


enum RecordDetailsAction {

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

struct RecordDetailsView: View {
  var store: Store<RecordDetailsState, RecordDetailsAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ScrollView {
          VStack {
            Text(viewStore.record.title)
            Text(viewStore.record.date.formatted())
          }
        }
      }
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
