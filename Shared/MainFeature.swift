//
//  MainFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture



struct MainState: Equatable {

  enum EditMode: Equatable {
    case inactive
    case transient
    case active
  }

  var editorState: EditorState
  var records: IdentifiedArrayOf<RecordState>
  var summaryState: SummaryViewState
  var title: String
  var editMode: EditMode = .inactive
}

enum MainAction {
  case editorAction(EditorAction)
  case recordAction(id: RecordState.ID, action: RecordAction)
  case summaryAction(SummaryViewAction)
  case editModeChanged(MainState.EditMode)
  case delete(IndexSet)
  case move(IndexSet, Int)
}

struct MainEnvironment {

}

let mainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
  combinedRecordReducer.forEach(
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
  summaryReducer
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
          if recordState.record.type == .expense {
            return partialResult - recordState.record.amount
          } else if recordState.record.type == .income {
            return partialResult + recordState.record.amount
          } else {
            fatalError("not handled record type")
          }
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
