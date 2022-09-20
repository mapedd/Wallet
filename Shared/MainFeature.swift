//
//  MainFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture



struct MainState: Equatable {
  init(
    editorState: EditorState,
    records: IdentifiedArrayOf<RecordState>,
    summaryState: SummaryViewState,
    title: String,
    editMode: MainState.EditMode = .inactive,
    statistics: StatisticsState? = nil
  ) {
    self.editorState = editorState
    self.records = records
    self.summaryState = summaryState
    self.title = title
    self.editMode = editMode
    self.statistics = statistics

    recalculateTotal()
  }


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
  var statistics: StatisticsState?

  var showStatistics: Bool {
    statistics != nil
  }

  mutating func recalculateTotal() {
    let sum = self.records.reduce(Decimal.zero, { partialResult, recordState in
      if recordState.record.type == .expense {
        return partialResult - recordState.record.amount
      } else if recordState.record.type == .income {
        return partialResult + recordState.record.amount
      } else {
        fatalError("not handled record type")
      }
    })

    self.summaryState.total = sum
  }

}

enum MainAction {
  case editorAction(EditorAction)
  case recordAction(id: RecordState.ID, action: RecordAction)
  case summaryAction(SummaryViewAction)
  case editModeChanged(MainState.EditMode)
  case delete(IndexSet)
  case move(IndexSet, Int)
  case statisticsAction(StatisticsAction)
  case showStatistics
  case hideStatistics
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
  statisticsReducer
    .optional()
    .pullback(
      state: \.statistics,
      action: /MainAction.statisticsAction,
      environment:{ _ in  StatisticsEnvironment() }
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

        state.recalculateTotal()

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
      state.recalculateTotal()
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

    case .showStatistics:

      state.statistics = .init(records: state.records)
      return .none
    case .hideStatistics:
      if let records = state.statistics?.records {
        state.records = records
      }
      state.statistics = nil
      return .none

    case .summaryAction(let summaryAction):
      switch summaryAction {
      case .showSummaryButtonTapped:
        return .task {
          return .showStatistics
        }
      case .hideSummary:
        return .task {
          return .hideStatistics
        }
      }
    case .recordAction(id: let id, action: let action):
      if case .detailsAction(let recordDetailsAction) = action {
        if case .deleteRecordTapped = recordDetailsAction {
          state.records.remove(id: id)
        }
      }
      return .none

    default:
      return .none
    }
  }
)
