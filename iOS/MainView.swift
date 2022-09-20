//
//  MainView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import SwiftUI
import ComposableArchitecture

extension MainState.EditMode {
  var iOSEditMode: SwiftUI.EditMode {
    switch self {
    case .active:
      return SwiftUI.EditMode.active
    case .transient:
      return SwiftUI.EditMode.transient
    case .inactive:
      return SwiftUI.EditMode.inactive
    }
  }
}

extension SwiftUI.EditMode {
  var walletEditMode: MainState.EditMode {
    switch self {
    case .active:
      return MainState.EditMode.active
    case .transient:
      return MainState.EditMode.transient
    case .inactive:
      return MainState.EditMode.inactive
    @unknown default:
      fatalError()
    }
  }
}

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
      .toolbar(content: {
        EditButton()
      })
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
