//
//  RecordDetails.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 10/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct RecordDetailsView: View {
  var store: Store<RecordDetailsState, RecordDetailsAction>

  var body: some View {
    WithViewStore(
      self.store, observe: \.renderableState, send: RecordDetailsAction.view
    ) { viewStore in
      NavigationView {
        ScrollView {
          VStack {
            title(viewStore)
            amount(viewStore)
            Spacer()
            Button("Delete") {
              viewStore.send(.deleteRecordTapped)
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
          }
        }
        .padding()
        .navigationTitle(Text(viewStore.date.formatted()))
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
      }

    }
  }

  func amount(_ viewStore: ViewStore<RecordDetailsState.RenderableState, RecordDetailsAction.RenderableAction>) -> some View {
    HStack(spacing: 0) {
      Text("Amount")
        .font(.title)
        .monospacedDigit()
      TextField(
        "amount",
        text: viewStore.binding(\.$amount)
      )
      .font(.title)
      .monospacedDigit()
      .keyboardType(.decimalPad)
      .padding()
    }
  }

  func title(_ viewStore: ViewStore<RecordDetailsState.RenderableState, RecordDetailsAction.RenderableAction>) -> some View {
    HStack(spacing: 0) {
      Text("Title")
        .font(.title)
        .monospacedDigit()
      TextField(
        "title",
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
