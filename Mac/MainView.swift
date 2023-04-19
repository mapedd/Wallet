//
//  MainView.swift
//  Wallet
//
//  Created by Tomek Kuzma on 06/02/2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import WalletCore

struct MainView : View {
  var store: StoreOf<Main>

  var screen = NSScreen.main?.visibleFrame

  var body: some View {
    WithViewStore(self.store, observe: { $0.records }) { viewStore in
      VStack {
        EditorView(
          store: self.store.scope(
            state: \.editorState,
            action: Main.Action.editorAction
          )
        )
        List {
          ForEach(viewStore.state) { record in
            RecordView(record: record)
          }
        }
      }
      .padding()
      .frame(minWidth: 250)
      .task {
        viewStore.send(.task)
      }
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(
      store: .init(
        initialState: .preview,
        reducer: Main()
      )
    )
  }
}
