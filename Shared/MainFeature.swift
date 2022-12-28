//
//  MainFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import AppApi

enum LocalError : Error {
  case cannotCreateRecord
}

struct MainState: Equatable {
  init(
    editorState: EditorState = .init(),
    records: IdentifiedArrayOf<RecordState> = [],
    summaryState: SummaryViewState = .init(),
    title: String = "Wallet",
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
  
  static let preview = Self.init(
    editorState: .init(categories: Category.previews),
    records: IdentifiedArray(uniqueElements: RecordState.sample),
    summaryState: .init(),
    title: "Wallet"
  )
  
}

enum MainAction {
  case editorAction(EditorAction)
  case recordAction(id: RecordState.ID, action: RecordAction)
  case summaryAction(SummaryViewAction)
  case editModeChanged(MainState.EditMode)
  case delete(IndexSet)
  case statisticsAction(StatisticsAction)
  case showStatistics
  case hideStatistics
  case logOut
  case logOutButtonTapped
  case mainViewAppeared
  case loadedRecords([RecordState])
  
  case recordCreated(Record.Detail)
  case recordCreateFailed(Error)
  
  case deleteSuccess
  case deleteFailed(Error)
}



struct MainEnvironment {
  var apiClient: APIClient
  var dateProvider: DateProvider
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
  .init { state, action, environment in
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
          currency: .pln,
          category: state.editorState.category
        )
        
        state.records.append(RecordState(record: newRecord))
        state.recalculateTotal()
        state.editorState = .init(categories: state.editorState.categories)
        
        return .task(
          operation: {
            let update = Record.Update(
              id: newRecord.id,
              title: newRecord.title,
              amount: newRecord.amount,
              currency: .pln,
              notes: nil,
              updated: environment.dateProvider.now
            )
            if let record = try await environment.apiClient.updateRecord(update) {
              return .recordCreated(record)
            }
            else {
              return .recordCreateFailed(LocalError.cannotCreateRecord)
            }
          },
          catch: { error in
            return .recordCreateFailed(error)
          }
        )
        
      default:
        return .none
      }
      
    case let .editModeChanged(editMode):
      state.editMode = editMode
      return .none
    case let .delete(indexSet):
      var records = [RecordState]()
      for i in indexSet {
        records.append(state.records[i])
      }
      
      state.records.remove(atOffsets: indexSet)
      state.recalculateTotal()
      
      let updates = records.map { record in
        Record.Update(
          id: record.id,
          updated: environment.dateProvider.now,
          deleted: environment.dateProvider.now
        )
      }
      
      return .task(
        operation: {
          
          for update in updates {
            let _ = try await environment.apiClient.updateRecord(update)
          }
          return .deleteSuccess
        },
        catch: { error in
          return .deleteFailed(error)
        }
      )
      
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
      
    case .logOutButtonTapped:
      return Effect(value: .logOut)
      
    case .mainViewAppeared:
      return .task {
        let records = try await environment.apiClient.listRecords()
        let recordStates = records.map { record in
          RecordState(
            record: .init(
              id: record.id,
              date: record.created,
              title: record.title,
              type: .expense,
              amount: record.amount,
              currency: .pln
            )
          )
        }
        return .loadedRecords(recordStates)
      }
      
    case .loadedRecords(let records):
      state.records = IdentifiedArrayOf<RecordState>(uniqueElements: records)
      return .none
    default:
      return .none
    }
  }
)
