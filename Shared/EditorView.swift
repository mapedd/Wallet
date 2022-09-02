//
//  EditorView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct EditorState: Equatable {
    @BindableState var text = "New Record"
    @BindableState var isExpense = true
    var addButtonDisabled = false
}

enum EditorAction:BindableAction, Equatable {
    case binding(BindingAction<EditorState>)
    case addButtonTapped
}

struct EditorEnvironment {

}

let editorReducer = Reducer<EditorState, EditorAction, EditorEnvironment> { state, action, _ in
    switch action {
    case .binding(\.$text):
        state.addButtonDisabled = state.text.isEmpty
        return .none
    case .addButtonTapped:
        return .none
    case .binding(_):
        return .none
    }
}
    .binding()

struct EditorView: View {
    var store: Store<EditorState, EditorAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                HStack {
                    TextField(
                        "Untitled Todo",
                        text: viewStore.binding(\.$text)
                    )
                    Button {
                        viewStore.send(.addButtonTapped)
                    } label: {
                        Text("Add")
                    }.disabled(viewStore.addButtonDisabled)


                }

                Toggle(
                    "Expense/Income",
                    isOn: viewStore.binding(\.$isExpense)
                )
            }
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(
            store: .init(
                initialState: .init(),
                reducer: editorReducer,
                environment: .init()
            )
        )
        .padding(40)
    }
}
