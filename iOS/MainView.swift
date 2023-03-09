//
//  MainView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import SwiftUI
import ComposableArchitecture
import WalletCore

extension Main.State {
  var iOSEditMode : SwiftUI.EditMode {
    self.editMode.iOSEditMode
  }
}

struct MainView : View {
  var store: StoreOf<Main>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        EditorView(
          store: self.store.scope(
            state: \.editorState,
            action: Main.Action.editorAction
          )
        )
        .padding(20)
        
        List {
          ForEachStore(
            self.store.scope(
              state: \.records,
              action: Main.Action.recordAction(id:action:)
            )
          ) {
            RecordView(store: $0)
          }
          .onDelete { viewStore.send(.delete($0)) }
        }
        SummaryView(
          store: self.store.scope(
            state: \.summaryState,
            action: Main.Action.summaryAction
          )
        )
      }
      .toolbar {
        Button("Log out") {
          viewStore.send(.logOutButtonTapped)
        }
        EditButton()
      }
      .sheet(
        store: self.store.scope(state: \.$statistics, action: Main.Action.statisticsAction)
      ) { store in
        NavigationStack {
          StatisticsView(store: store)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                  viewStore.send(.statisticsAction(.dismiss))
                }
              }
            }
        }
        
      }
      .environment(
        \.editMode,
         viewStore.binding(
          get: \.iOSEditMode,
          send: { value in return Main.Action.editModeChanged(value.walletEditMode) }
         )
      )
      .navigationTitle(viewStore.title)
      .navigationBarTitleDisplayMode(.inline)
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
