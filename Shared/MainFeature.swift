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
      editorState: Editor.State = .init(currency: .usd),
      records: IdentifiedArrayOf<Record.State> = [],
      summaryState: Summary.State = .init(baseCurrencyCode: "USD"),
      title: String = "Wallet",
      editMode: State.EditMode = .inactive,
      statistics: Statistics.State? = nil,
      categories: [Category] = []
    ) {
      self.editorState = editorState
      self.records = records
      self.summaryState = summaryState
      self.title = title
      self.editMode = editMode
      self.statistics = statistics
      self.categories = categories
      
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
    var categories: [Category]
    
    var showStatistics: Bool {
      statistics != nil
    }
    
    var currentCurrencyCode: Currency.Code {
      if let first = records.first {
        return first.record.currencyCode
      }
      return Currency.List.usd.code
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
      self.summaryState.baseCurrencyCode = currentCurrencyCode
    }
    
    static let preview = Self.init(
      editorState: .init(
        currency: .preview,
        categories: Category.previews
      ),
      records: IdentifiedArray(uniqueElements: Record.State.sample),
      summaryState: .init(baseCurrencyCode: "USD"),
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
    case detailsAction(Record.Action)
    case showStatistics
    case hideStatistics
    case logOut
    case logOutButtonTapped
    case mainViewAppeared
    
    case loadingRecordsFailed(Swift.Error)
    case loadedRecords([Record.State])
    
    case loadingCategoriesFailed(Swift.Error)
    case loadedCategories([Category])
    
    case dismissDetails(Record.State?)
    
    case recordCreated(AppApi.Record.Detail)
    case recordCreateFailed(Error)
    
    case deleteSuccess
    case deleteFailed(Error)
    
    case updateSuccess
    case updateFailed(Error)
  }
  
  func deleting(_ record: MoneyRecord) -> EffectTask<Action> {
    let update = AppApi.Record.Update(
      id: record.id,
      updated: dateProvider.now,
      deleted: dateProvider.now
    )
    
    return .task(
      operation: {
        let _ = try await apiClient.updateRecord(update)
        return .deleteSuccess
      },
      catch: { error in
        return .deleteFailed(error)
      }
    )
  }
  
  func saving(_ record: MoneyRecord) -> EffectTask<Action> {
    
    var categoryIds: [UUID] = []
    if let category = record.category {
      categoryIds.append(category.id)
    }
    let update = AppApi.Record.Update(
      id: record.id,
      title: record.title,
      amount: record.amount,
      type: record.apiRecordType,
      currencyCode: record.currencyCode,
      notes: record.notes,
      categoryIds: categoryIds,
      updated: dateProvider.now
    )
    
    return .task(
      operation: {
        let _ = try await apiClient.updateRecord(update)
        return .updateSuccess
      },
      catch: { error in
        return .updateFailed(error)
      }
    )
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
            notes: "",
            type: state.editorState.recordType,
            amount: Decimal(string: state.editorState.amount) ?? Decimal.zero,
            currencyCode: state.editorState.currency.code,
            category: state.editorState.category
          )
          
          let recordState = Record.State(
            record: newRecord,
            categories: state.categories
          )
          
          state.records.append(recordState)
          state.recalculateTotal()
          state.editorState = .init(
            currency: .preview,
            categories: state.editorState.categories
          )
          
          return .task(
            operation: {
              let update = AppApi.Record.Update(
                id: newRecord.id,
                title: newRecord.title,
                amount: newRecord.amount,
                type: newRecord.apiRecordType,
                currencyCode: newRecord.currencyCode,
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
      case .recordAction(let id, let recordAction):
        switch recordAction {
        case .detailsAction(let recordDetailsAction):
          switch recordDetailsAction {
          case .deleteRecordTapped:
            if let record = state.records[id: id] {
              state.records.remove(id: id)
              state.recalculateTotal()
              return deleting(record.record)
            }
            return .none
          default:
            return .none
          }
        case .setSheet(isPresented: let presented):
          if !presented, let record = state.records[id: id] {
            return saving(record.record)
          }
          return .none
        default:
          return .none
        }
        
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
        
        state.statistics = .init(
          records: state.records,
          baseCurrency: state.currentCurrencyCode
        )
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
        
      case .logOutButtonTapped:
        return Effect(value: .logOut)
        
      case .mainViewAppeared:
        return .merge(
          .task(
            operation: {
              let records = try await apiClient.listRecords()
              let recordStates = records.map { $0.asRecordState }
              return .loadedRecords(recordStates)
            },
            catch: { error in
              return .loadingRecordsFailed(error)
            }
          ),
          .task(
            operation: {
              let categories = try await apiClient.listCategories()
              let localCategeries = categories.map { $0.asLocaleCategory }
              return .loadedCategories(localCategeries)
            },
            catch: { error in
              return .loadingCategoriesFailed(error)
            }
          )
        )
        
      case .loadedRecords(let records):
        state.records = IdentifiedArrayOf<Record.State>(uniqueElements: records)
        return .none
      case .loadedCategories(let categories):
        state.editorState.categories = categories
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

extension AppApi.Record.Detail {
  var asRecordState: Record.State {
    Record.State(
      record: .init(
        id: id,
        date: created,
        title: title,
        notes: notes ?? "",
        type: clientRecordType,
        amount: amount,
        currencyCode: currencyCode
      ),
      categories: []
    )
  }
}

//extension AppApi.Currency {
//  var asClientCurrency: Wallet_IOS.Currency {
//    switch self {
//    case .usd:
//      return .usd
//    case .pln:
//      return .pln
//    }
//  }
//}

extension MoneyRecord {
  var apiRecordType: AppApi.RecordType {
    switch self.type {
    case .income:
      return AppApi.RecordType.income
    case .expense:
      return AppApi.RecordType.expense
    }
  }
}

extension AppApi.Record.Detail {
  var clientRecordType: MoneyRecord.RecordType {
    switch self.type {
    case .income:
      return MoneyRecord.RecordType.income
    case .expense:
      return MoneyRecord.RecordType.expense
    }
  }
}
extension AppApi.RecordCategory.Detail {
  var asLocaleCategory: Wallet_IOS.Category {
    .init(
      name: self.name,
      id: self.id,
      color: self.color
    )
  }
}
