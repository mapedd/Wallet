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

struct Main : ReducerProtocol {
  
  struct State: Equatable {
    init(
      editorState: Editor.State = .init(),
      records: IdentifiedArrayOf<Record.State> = [],
      summaryState: Summary.State = .init(),
      title: String = "Wallet",
      editMode: State.EditMode = .inactive,
      statistics: Statistics.State? = nil
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
    
    var editorState: Editor.State
    var records: IdentifiedArrayOf<Record.State>
    var summaryState: Summary.State
    var title: String
    var editMode: EditMode = .inactive
    var statistics: Statistics.State?
    
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
      records: IdentifiedArray(uniqueElements: Record.State.sample),
      summaryState: .init(),
      title: "Wallet"
    )
    
  }
  
  enum Action {
    case editorAction(Editor.Action)
    case recordAction(id: Record.State.ID, action: Record.Action)
    case summaryAction(Summary.Action)
    case editModeChanged(State.EditMode)
    case delete(IndexSet)
    case statisticsAction(Statistics.Action)
    case showStatistics
    case hideStatistics
    case logOut
    case logOutButtonTapped
    case mainViewAppeared
    case loadedRecords([Record.State])
    
    case recordCreated(AppApi.Record.Detail)
    case recordCreateFailed(Error)
    
    case deleteSuccess
    case deleteFailed(Error)
  }
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.dateProvider) var dateProvider
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.editorState, action: /Action.editorAction) {
      Editor()
    }
    Scope(state: \.summaryState, action: /Action.summaryAction) {
      Summary()
    }
    Reduce { state, action in
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
          
          state.records.append(Record.State(record: newRecord))
          state.recalculateTotal()
          state.editorState = .init(categories: state.editorState.categories)
          
          return .task(
            operation: {
              let update = AppApi.Record.Update(
                id: newRecord.id,
                title: newRecord.title,
                amount: newRecord.amount,
                currency: .pln,
                notes: nil,
                updated: dateProvider.now
              )
              if let record = try await apiClient.updateRecord(update) {
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
        var records = [Record.State]()
        for i in indexSet {
          records.append(state.records[i])
        }
        
        state.records.remove(atOffsets: indexSet)
        state.recalculateTotal()
        
        let updates = records.map { record in
          AppApi.Record.Update(
            id: record.id,
            updated: dateProvider.now,
            deleted: dateProvider.now
          )
        }
        
        return .task(
          operation: {
            
            for update in updates {
              let _ = try await apiClient.updateRecord(update)
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
          let records = try await apiClient.listRecords()
          let recordStates = records.map { record in
            Record.State(
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
        state.records = IdentifiedArrayOf<Record.State>(uniqueElements: records)
        return .none
      default:
        return .none
      }
    }
    .forEach(\.records, action: /Action.recordAction(id:action:)) {
      Record()
    }
    .ifLet(\.statistics, action: /Action.statisticsAction) {
      Statistics()
    }
    
  }
}
