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
            MainView(store: .init(
                initialState: .init(
                    editorState: .init(),
                    recordListState: .init()
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
    var recordListState: RecordListState
    //    var title: String
    //    var editMode: EditMode = .inactive
    //
    //    var todos: IdentifiedArrayOf<MoneyRecord> = []
}

enum MainAction: Equatable {
    case editorAction(EditorAction)
    case recordListAction(RecordListAction)
}

struct MainEnvironment {

}

let mainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
    editorReducer
        .pullback(
            state: \.editorState,
            action: /MainAction.editorAction,
            environment: { _ in EditorEnvironment() }
        ),
    recordListReducer
        .pullback(
            state: \.recordListState,
            action: /MainAction.recordListAction,
            environment: { _ in RecordListEnvironment() }
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
                    type: state.editorState.isExpense ? .expense : .income,
                    amount: Decimal(123),
                    currency: .pln
                )
                state.recordListState.records.append(newRecord)
                state.editorState = .init()
                return .none
            default:
                return .none
            }

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
                RecordListView(
                    store: self.store.scope(
                        state: \.recordListState,
                        action: MainAction.recordListAction
                    )
                )
                SummaryView()
            }
        }
    }
}

struct SummaryView: View {
    var body: some View {
        Text("summary")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
