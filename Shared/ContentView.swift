//
//  ContentView.swift
//  Shared
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture
import IdentifiedCollections

struct ContentView: View {
  var body: some View {
    NavigationView {
      MainView(
        store: .init(
          initialState: .init(
            editorState: .init(),
            records: [],
            summaryState: .init(),
            title: "Wallet"
          ),
          reducer: mainReducer,
          environment: MainEnvironment()
        )
      )
    }
  }
}

struct MoneyRecord: Equatable, Identifiable {
  enum RecordType: Equatable {
    case income
    case expense
  }
  let id: UUID
  let date: Date
  let title: String
  let type: RecordType
  let amount: Decimal
  let currency: Currency
}

enum Currency: Equatable {
  case pln
  case usd
  case eur
  case gbp
}

struct MainState: Equatable {
  var editorState: EditorState
  var records: IdentifiedArrayOf<RecordState>
  var summaryState: SummaryViewState
  var title: String
  var editMode: EditMode = .inactive
}

enum MainAction: Equatable {
  case editorAction(EditorAction)
  case recordAction(id: RecordState.ID, action: RecordAction)
  case summaryAction(SummaryViewAction)
  case editModeChanged(EditMode)
  case delete(IndexSet)
  case move(IndexSet, Int)
}

struct MainEnvironment {

}

let mainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
    recordReducer.forEach(
      state: \.records,
      action: /MainAction.recordAction(id:action:),
      environment: { _ in RecordEnvironment() }
    ),
  editorReducer
    .pullback(
      state: \.editorState,
      action: /MainAction.editorAction,
      environment: { _ in EditorEnvironment() }
    ),
  summaryViewReducer
    .pullback(
      state: \.summaryState,
      action: /MainAction.summaryAction,
      environment: { _ in SummaryViewEnvironment() }
    ),
  .init { state, action, _ in
    switch action {
    case let .editorAction(editorAction):
      switch editorAction {
      case .addButtonTapped:
        let newRecord = MoneyRecord(
          id: .init(),
          date: .init(),
          title: state.editorState.text,
          type: state.editorState.recordType,
          amount: Decimal(string: state.editorState.amount) ?? Decimal.zero,
          currency: .pln
        )

        state.records.append(RecordState(record: newRecord))

        let sum = state.records.reduce(Decimal.zero, { partialResult, recordState in
            recordState.record.amount + partialResult
        })

        state.summaryState.total = sum

        state.editorState = .init()
        return .none
      default:
        return .none
      }

    case let .editModeChanged(editMode):
      state.editMode = editMode
      return .none
    case let .delete(indexSet):
      state.records.remove(atOffsets: indexSet)
      return .none
    case var .move(source, destination):
      let source = IndexSet(
        source
          .map { state.records[$0] }
          .compactMap { state.records.index(id: $0.id) }
      )
      let destination =
        state.records.index(id: state.records[destination].id)
        ?? destination
      state.records.move(fromOffsets: source, toOffset: destination)
        return .none
    default:
      return .none
    }
  }
)

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
          get: \.editMode,
          send: MainAction.editModeChanged
        )
      )
      .navigationTitle(viewStore.title)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
