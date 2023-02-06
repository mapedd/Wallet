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
    var conversions: ConversionResult?
    
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
      
      guard let conversions else {
        print("not loaded conversions")
        return
      }
      
      let sum = self.records.reduce(Decimal.zero, { partialResult, recordState in
        let recordCurrency = recordState.record.currencyCode
       guard
        let conversion: Float = conversions.data[recordCurrency]
        else {
          return partialResult
        }
        let convertedAmount = recordState.record.amount / Decimal(floatLiteral: Double(conversion))
        if recordState.record.type == .expense {
          return partialResult - convertedAmount
        } else if recordState.record.type == .income {
          return partialResult + convertedAmount
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
    
    case loadedConversions(ConversionResult)
    case loadingConversionsFailed(Swift.Error)
    
    case dismissDetails(Record.State?)
    
    case recordCreated(AppApi.Record.Detail)
    case recordCreateFailed(Error)
    
    case deleteSuccess
    case deleteFailed(Error)
    
    case updateSuccess
    case updateFailed(Error)
  }
  
  func deleting(_ record: MoneyRecord) -> EffectTask<Action> {
    var update = record.asUpdate
    update.updated = dateProvider.now
    update.deleted = dateProvider.now
    
    return .task(
      operation: {[update] in 
        let _ = try await apiClient.updateRecord(update)
        return .deleteSuccess
      },
      catch: { error in
        return .deleteFailed(error)
      }
    )
  }
  
  func saving(_ record: MoneyRecord) -> EffectTask<Action> {
    
    let categoryIds = record.categories.map { $0.id }
    
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
          var categories: [Category] = []
          if let newCategory = state.editorState.category {
            categories.append(newCategory)
          }
          let newRecord = MoneyRecord(
            id: .init(),
            date: .init(),
            title: state.editorState.text,
            notes: "",
            type: state.editorState.recordType,
            amount: Decimal(string: state.editorState.amount) ?? Decimal.zero,
            currencyCode: state.editorState.currency.code,
            categories: categories
          )
          
          let recordState = Record.State(
            record: newRecord
          )
          
          state.records.append(recordState)
          state.recalculateTotal()
          state.editorState = .init(
            currency: .preview,
            categories: state.editorState.categories
          )
          
          let update = AppApi.Record.Update(
            id: newRecord.id,
            title: newRecord.title,
            amount: newRecord.amount,
            type: newRecord.apiRecordType,
            currencyCode: newRecord.currencyCode,
            notes: newRecord.notes,
            categoryIds: categories.map(\.id),
            updated: dateProvider.now
          )
          
          return .task(
            operation: {
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
        
        let updates = records.map { recordState in
          var update = recordState.record.asUpdate
          update.updated = dateProvider.now
          update.deleted = dateProvider.now
          return update
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
        let base = state.currentCurrencyCode
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
          ),
          .task(
            operation: {
              let conversions = try await apiClient.conversions(base)
              return .loadedConversions(conversions)
            },
            catch: { error in
              return .loadingConversionsFailed(error)
            }
          )
        )
        
      case .loadedRecords(let records):
        state.records = IdentifiedArrayOf<Record.State>(uniqueElements: records)
        state.recalculateTotal()
        return .none
      case .loadedCategories(let categories):
        state.editorState.categories = categories
        return .none
      case .loadedConversions(let conversions):
        state.conversions = conversions
        state.recalculateTotal()
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
        currencyCode: currencyCode,
        categories: categories.map { $0.asLocaleCategory }
      )
    )
  }
}

extension MoneyRecord {
  var asUpdate: AppApi.Record.Update {
    .init(
      id: id,
      title: title,
      amount: amount,
      type: apiRecordType,
      currencyCode: currencyCode,
      notes: notes,
      categoryIds: categories.map(\.id),
      updated: date,
      deleted: nil
    )
  }
}

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
  var asLocaleCategory: Category {
    .init(
      name: self.name,
      id: self.id,
      color: self.color
    )
  }
}
