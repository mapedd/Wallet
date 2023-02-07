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
    WithViewStore(self.store) { viewStore in
      VStack {
        EditorView(
          store: self.store.scope(
            state: \.editorState,
            action: Main.Action.editorAction
          )
        )
        .padding(40)
        List {
          ForEachStore(
            self.store.scope(
              state: \.records,
              action: Main.Action.recordAction(id:action:)
            )
          ) {
            RecordView(store: $0)
          }
        }
        .frame(minWidth: 250)
      }
      .ignoresSafeArea(.all, edges: .all)
      .frame(width: screen!.width / 3.8, height: screen!.height / 2.0)
      .onAppear{
        viewStore.send(.mainViewAppeared)
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
