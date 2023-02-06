//
//  MainView.swift
//  Wallet
//
//  Created by Tomek Kuzma on 06/02/2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct MainView : View {
  var store: StoreOf<Main>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        VStack {
          EditorView(
            store: self.store.scope(
              state: \.editorState,
              action: Main.Action.editorAction
            )
          )
          List() {
            ForEach(viewStore.records) { recordState in
              Text(recordState.record.title)
                .font(.headline)
            }
            
          }
          .frame(minWidth: 250)
        }
      }
    }
  }
}
