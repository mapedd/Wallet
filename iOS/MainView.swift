//
//  MainView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import SwiftUI
import ComposableArchitecture


extension MainState {
  var iOSEditMode : SwiftUI.EditMode {
    self.editMode.iOSEditMode
  }
}

struct MainView : View {
  var store: Store<MainState, MainAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        EditorView(
          store: self.store.scope(
            state: \.editorState,
            action: MainAction.editorAction
          )
        )
        .padding(20)

        List {
          ForEachStore(
            self.store.scope(state: \.records, action: MainAction.recordAction(id:action:))
          ) {
            RecordView(store: $0)
          }
          .onDelete { viewStore.send(.delete($0)) }
          .onMove { viewStore.send(.move($0, $1)) }
        }
        SummaryView(
          store: self.store.scope(
            state: \.summaryState,
            action: MainAction.summaryAction
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
        isPresented: viewStore.binding(
          get: \.showStatistics,
          send: { $0 ? MainAction.showStatistics : MainAction.hideStatistics }
        )
      ) {
        IfLetStore(
          self.store.scope(
            state: \.statistics,
            action: MainAction.statisticsAction
          )
        ) {
          StatisticsView(store: $0)
        }
      }
      .environment(
        \.editMode,
         viewStore.binding(
          get: \.iOSEditMode,
          send: { value in return MainAction.editModeChanged(value.walletEditMode) }
         )
      )
      .navigationTitle(viewStore.title)
    }
  }
  
}
