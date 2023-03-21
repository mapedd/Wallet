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
  
  struct ViewState: Equatable {
    let editRecordID: MoneyRecord.ID?
    let records: IdentifiedArrayOf<MoneyRecord>
    let loading: Bool
    let iOSEditMode: SwiftUI.EditMode
    
    init(state: Main.State) {
      self.editRecordID = state.editedRecord?.record.id
      self.records = state.records
      self.loading = state.loading
      self.iOSEditMode = state.iOSEditMode
    }
  }
  
  var body: some View {
    WithViewStore(
      self.store,
      observe: ViewState.init
    ) { (viewStore: ViewStore<ViewState, Main.Action>) in
      VStack {
        EditorView(
          store: self.store.scope(
            state: \.editorState,
            action: Main.Action.editorAction
          )
        )
        .padding(20)
        
        List {
          ForEach(viewStore.records) { record in
            NavigationLinkStore(
              store: self.store.scope(
                state: \.editedRecord,
                action: Main.Action.editRecord
              ),
              id: record.id,
              action: {
                viewStore.send(.didTapRecord(id: record.id))
              },
              destination: { store in
                RecordDetailsView(store: store)
              },
              label: {
                RecordView(record: record)
              }
            )
          }
          .onDelete {
            viewStore.send(.delete($0))
          }
        }
        .refreshable {
          await viewStore.send(.refresh, while: \.loading)
        }
        
        SummaryView(
          store: self.store.scope(
            state: \.summaryState,
            action: Main.Action.summaryAction
          )
        )
      }
      .fullScreenCover(
        store: self.store.scope(state: \.settings, action: Main.Action.settings)
      ) { store in
        NavigationView {
          SettingsView(store: store)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                  viewStore.send(.settings(.dismiss))
                }
              }
            }
        }
      }
      .sheet(
        store: self.store.scope(state: \.statistics, action: Main.Action.statisticsAction)
      ) { store in
        NavigationView {
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
      .toolbar {
        
        ToolbarItem(
          placement: .navigationBarLeading
        ) {
          Button {
            viewStore.send(.settingsButtonTapped)
          } label: {
            Image(systemName: "gearshape")
          }
        }
        

        ToolbarItem {
          EditButton()
        }
      }
      .environment(
        \.editMode,
         viewStore.binding(
          get: \.iOSEditMode,
          send: { value in return Main.Action.editModeChanged(value.walletEditMode) }
         )
      )
      .navigationTitle("Wallet")
      .navigationBarTitleDisplayMode(.inline)
      .task {
        viewStore.send(.task)
      }
    }
  }
  
}


public extension View {
  func alert<Action>(
    store: Store<AlertState<Action>?, PresentationAction<Action>>
  ) -> some View {
    WithViewStore(
      store,
      observe: { $0 },
      removeDuplicates: { ($0 != nil) == ($1 != nil) }
    ) { viewStore in
      self.alert(
        unwrapping: Binding(
          get: { viewStore.state },
          set: { newState in
            if viewStore.state != nil {
              viewStore.send(.dismiss)
            }
          }
        )
      ) { action in
        if let action {
          viewStore.send(.presented(action))
        }
      }
    }
  }
}


struct NavigationLinkStore<ChildState: Identifiable, ChildAction, Destination: View, Label: View>: View {
  let store: Store<ChildState?, PresentationAction<ChildAction>>
  let id: ChildState.ID?
  let action: () -> Void
  @ViewBuilder let destination: (Store<ChildState, ChildAction>) -> Destination
  @ViewBuilder let label: Label
  
  var body: some View {
    WithViewStore(self.store, observe: { $0?.id == self.id }) { viewStore in
      NavigationLink(
        isActive: Binding(
          get: {
            viewStore.state
          },
          set: { isActive in
            if isActive {
              self.action()
            } else if viewStore.state {
              viewStore.send(.dismiss)
            }
          }
        ),
        destination: {
          IfLetStore(
            self.store.scope(state: returningLastNonNilValue { $0 }, action: { .presented($0) })
          ) { store in
            self.destination(store)
          }
        },
        label: { self.label }
      )
    }
  }
}


func returningLastNonNilValue<A, B>(
  _ f: @escaping (A) -> B?
) -> (A) -> B? {
  var lastValue: B?
  return { a in
    lastValue = f(a) ?? lastValue
    return lastValue
  }
}


struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      MainView(
        store: .init(
          initialState: .preview,
          reducer: Main()
        )
      )
    }
  }
}
