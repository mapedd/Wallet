//
//  ContentView.swift
//  Wallet (iOS)
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
  let store: Store<MainState, MainAction>

  @State var selectedRecord: RecordState?

    var body: some View {
      WithViewStore(self.store) { viewStore in
        NavigationView {
          VStack {
            EditorView(
              store: self.store.scope(
                state: \.editorState,
                action: MainAction.editorAction
              )
            )
            List() {

              ForEach(viewStore.records) { recordState in
                Text(recordState.record.title)
                  .onTapGesture {
                    selectedRecord = recordState
                  }
                .font(.headline)
              }

            }
            .frame(minWidth: 250)
          }

          detail
            .frame(minWidth: 250)
        }
        .frame(minWidth: 500)
      }
    }

  @ViewBuilder var detail: some View {
    if let selectedRecord = selectedRecord {
      DetailView(
        recordState: selectedRecord
      )
    } else {
      Text("nothing selected")
    }
  }
}

struct DetailView: View {
  var recordState: RecordState
  var body: some View {
    Text(recordState.record.title)
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
          store: .init(
            initialState: .preview,
            reducer: mainReducer,
            environment: MainEnvironment()
          )
        )
    }
}
