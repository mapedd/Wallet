//
//  MainFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import CustomDump
import Logging
import AppApi
import WalletCoreDataModel

enum LocalError : Error {
  case cannotCreateRecord
}

public struct Main : ReducerProtocol {
  
  let logger = Logger(label: "com.mapedd.wallet.main")

  public init() {}
  
  public struct State: Equatable {
    public init(
      editorState: Editor.State = .init(currency: .usd),
      records: IdentifiedArrayOf<MoneyRecord> = [],
      summaryState: Summary.State = .init(baseCurrencyCode: "USD"),
      title: String = "Wallet",
      editMode: State.EditMode = .inactive,
      statistics: Statistics.State? = nil,
      categories: [MoneyRecord.Category] = [],
      editedRecord: RecordDetails.State? = nil,
      settings: Settings.State? = nil,
      loading: Bool = false
    ) {
      self.editorState = editorState
      self.records = records
      self.summaryState = summaryState
      self.title = title
      self.editMode = editMode
      self.statistics = statistics
      self.categories = categories
      self.editedRecord = editedRecord
      self.settings = settings
      self.loading = loading
      recalculateTotal()
    }
    
    
    public enum EditMode: Equatable {
      case inactive
      case transient
      case active
    }
    
    public var editorState: Editor.State
    public var records: IdentifiedArrayOf<MoneyRecord>
    public var summaryState: Summary.State
    public var title: String
    public var editMode: EditMode = .inactive
    public var statistics: Statistics.State?
    public var categories: [MoneyRecord.Category]
    public var conversions: ConversionResult?
    public var editedRecord: RecordDetails.State?
    public var settings: Settings.State?
    public var loading: Bool
    public var initialLoadDone = false
    
    var currentCurrencyCode: Currency.Code {
      if let first = records.first {
        return first.currencyCode
      }
      return Currency.List.usd.code
    }
    
    mutating func recalculateTotal() {
      
      guard let conversions else {
        print("not loaded conversions")
        return
      }
      
      let sum = self.records.reduce(Decimal.zero, { partialResult, record in
        let recordCurrency = record.currencyCode
       guard
        let conversion: Float = conversions.data[recordCurrency]
        else {
          return partialResult
        }
        let convertedAmount = record.amount / Decimal(floatLiteral: Double(conversion))
        if record.type == .expense {
          return partialResult - convertedAmount
        } else if record.type == .income {
          return partialResult + convertedAmount
        } else {
          fatalError("not handled record type")
        }
      })
      
      self.summaryState.total = sum
      self.summaryState.baseCurrencyCode = currentCurrencyCode
    }
    
    public static let preview = Self.init(
      editorState: .init(
        currency: .preview,
        categories: MoneyRecord.Category.previews
      ),
      records: IdentifiedArray(uniqueElements: [.init(
        id: UUID(),
        date: Date(),
        title: "New Record",
        notes: "Notes",
        type: .expense,
        amount: Decimal(string: "10.0")!,
        currencyCode: "USD",
        categories: []
      )]),
      summaryState: .init(baseCurrencyCode: "USD"),
      title: "Wallet"
    )
    
  }
  
  public enum Action: Equatable {
    case editorAction(Editor.Action)
    case editRecord(PresentationAction<RecordDetails.Action>)
    case summaryAction(Summary.Action)
    case editModeChanged(State.EditMode)
    case delete(IndexSet)
    case statisticsAction(PresentationAction<Statistics.Action>)
    case settings(PresentationAction<Settings.Action>)
    case showStatistics
    case hideStatistics
    
    case settingsButtonTapped
    case task
    case refresh
    
    case recordChanged(UUID)
    
    case loadingRecordsFailed(String)
    case loadedRecords([MoneyRecord])
    
    case loadingCategoriesFailed(String)
    case loadedCategories([MoneyRecord.Category])
    
    case loadedConversions(ConversionResult)
    case loadingConversionsFailed(String)
    
    
    case recordCreated(AppApi.Record.Detail)
    case recordCreateFailed(String)
    
    case deleteSuccess
    case deleteFailed(String)
    
    case updateSuccess
    case updateFailed(String)
    
    case didTapRecord(id: MoneyRecord.ID)
    
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case logOut
      case deleteAccount
    }
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
        return .deleteFailed(error.localizedDescription)
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
        return .updateFailed(error.localizedDescription)
      }
    )
  }
  
  
  func moneyRecord(from editorState: Editor.State) -> MoneyRecord {
    var categories: [MoneyRecord.Category] = []
    if let newCategory = editorState.category {
      categories.append(newCategory)
    }
    let newRecord = MoneyRecord(
      id: .init(),
      date: .init(),
      title: editorState.text,
      notes: "",
      type: editorState.recordType,
      amount: Decimal(string: editorState.amount) ?? Decimal.zero,
      currencyCode: editorState.currency.code,
      categories: categories
    )
    return newRecord
  }
  
  func creating(newRecord: MoneyRecord) -> EffectTask<Action> {
   
    let update = AppApi.Record.Update(
      id: newRecord.id,
      title: newRecord.title,
      amount: newRecord.amount,
      type: newRecord.apiRecordType,
      currencyCode: newRecord.currencyCode,
      notes: newRecord.notes,
      categoryIds: newRecord.categories.map(\.id),
      updated: dateProvider.now
    )
    
    return .task(
      operation: {
        if let record = try await apiClient.updateRecord(update) {
          return .recordCreated(record)
        }
        else {
          return .recordCreateFailed(LocalError.cannotCreateRecord.localizedDescription)
        }
      },
      catch: { error in
        return .recordCreateFailed(error.localizedDescription)
      }
    )
  }
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.dateProvider) var dateProvider
  
  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.editorState, action: /Action.editorAction) {
      Editor()
    }
    Scope(state: \.summaryState, action: /Action.summaryAction) {
      Summary()
    }
    Reduce { state, action in
      switch action {
      case .refresh:
        return .task(
          operation: {
            let records = try await apiClient.listRecords()
            let recordStates = records.map { $0.asMoneyRecord }
            return .loadedRecords(recordStates)
          },
          catch: { error in
            return .loadingRecordsFailed(error.localizedDescription)
          }
        )
      case let .editorAction(editorAction):
        switch editorAction {
        case .addButtonTapped:
          
          let newRecord = moneyRecord(from: state.editorState)
          
          state.records.append(newRecord)
          state.recalculateTotal()
          state.editorState = .init(
            currency: .preview,
            categories: state.editorState.categories
          )
          
          return creating(newRecord: newRecord)
          
        default:
          return .none
        }
        
      case let .editModeChanged(editMode):
        state.editMode = editMode
        return .none
      
      case let .delete(indexSet):
        var records = [MoneyRecord]()
        for i in indexSet {
          records.append(state.records[i])
        }

        state.records.remove(atOffsets: indexSet)
        state.recalculateTotal()

        let updates = records.map { record in
          var update = record.asUpdate
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
            return .deleteFailed(error.localizedDescription)
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
        
      case .settingsButtonTapped:
        state.settings = Settings.State(user: .init(email: "email", id: .init()))
        return .none
        
      case .settings(.presented(.delegate(.logOutRequested))):
        return Effect(value: .delegate(.logOut))
      case .settings(.presented(.delegate(.deleteAcountRequested))):
        return Effect(value: .delegate(.deleteAccount))
      case .task:

        if state.initialLoadDone  {
          return .none
        }

        state.initialLoadDone = true

        state.loading = true

        let base = state.currentCurrencyCode
        return .merge(
          .task(
            operation: {
              let records = try await apiClient.listRecords()
              let recordStates = records.map { $0.asMoneyRecord }
              return .loadedRecords(recordStates)
            },
            catch: { error in
              return .loadingRecordsFailed(error.localizedDescription)
            }
          ),
          .task(
            operation: {
              let categories = try await apiClient.listCategories()
              let localCategeries = categories.map { $0.asLocaleCategory }
              return .loadedCategories(localCategeries)
            },
            catch: { error in
              return .loadingCategoriesFailed(error.localizedDescription)
            }
          ),
          .task(
            operation: {
              let conversions = try await apiClient.conversions(base)
              return .loadedConversions(conversions)
            },
            catch: { error in
              return .loadingConversionsFailed(error.localizedDescription)
            }
          ),
          .fireAndForget {
            do {
              try await apiClient.subscribeToRecordChanges(UUID())
            } catch {
              logger.error("error subscribing to record changed \(error)")
            }
          },
          .run { send in
            logger.info("running websocket listener")
            do {
              for try await recordId in apiClient.recordsChanged() {
                logger.info("received websocket message record change")
                  await send(.recordChanged(recordId))
              }
            } catch {
              logger.error("error receiving record changed \(error)")
            }

          }
        )
        
      case .loadedRecords(let records):
        state.records = IdentifiedArray(uniqueElements: records)
        state.recalculateTotal()
        state.loading = false
        return .none
      case .loadedCategories(let categories):
        state.editorState.categories = categories
        return .none
      case .loadedConversions(let conversions):
        state.conversions = conversions
        state.recalculateTotal()
        return .none
        
      case .recordChanged(let recordId):
        // we should refresh record or fetch it here
        logger.info("record chagned event \(recordId)")
        return .none
      case .didTapRecord(id: let recordId):
        guard let record = state.records[id: recordId] else {
          return .none
        }
        state.editedRecord = RecordDetails.State(
          record: record,
          availableCategories: state.categories
        )
        return .none
      case .editRecord(.dismiss):
        guard let record = state.editedRecord?.record
        else { return .none }
        let oldRecord = state.records[id: record.id]
        
        if oldRecord != record {
          logger.notice("dismissed edit, changed detected, saving to API")
          let message = Logger.Message(stringLiteral: diff(oldRecord, record)!)
          logger.notice(message)
          return saving(record)
        }
        logger.notice("dismissed edit, no changed detected")
        return .none
      case .editRecord(.presented(.alert(.presented(RecordDetails.Action.Alert.deleteConfirm)))):
        
        guard let edited = state.editedRecord else {
          return .none
        }
        
        state.records.remove(id: edited.record.id)
        state.recalculateTotal()

        let updates = [edited.record.asUpdate]

        return .task(
          operation: {

            for update in updates {
              let _ = try await apiClient.updateRecord(update)
            }
            return .deleteSuccess
          },
          catch: { error in
            return .deleteFailed(error.localizedDescription)
          }
        )
      
      case .editRecord:
        return .none
      case .statisticsAction(_):
        return .none
      case .delegate:
        return .none
      case .loadingRecordsFailed(_):
        state.loading = false
        return .none
      case .loadingCategoriesFailed(_):
        return .none
      case .loadingConversionsFailed(_):
        return .none
      case .recordCreated(_):
        return .none
      case .recordCreateFailed(_):
        return .none
      case .deleteSuccess:
        return .none
      case .deleteFailed(_):
        return .none
      case .updateSuccess:
        return .none
      case .updateFailed(_):
        return .none
      case .settings(.presented(.delegate(.attemptImport(let records)))):
        let moneyRecords = records.map { $0.asMoneyRecord }
        state.records.append(contentsOf: moneyRecords )
        let updates = moneyRecords.map {
          creating(newRecord: $0)
        }
        return .merge(updates)
        
      case .settings:
        return .none
      }
    }
    .ifLet(\.editedRecord, action: /Action.editRecord) {
      RecordDetails()
    }
    .ifLet(\.settings, action: /Action.settings) {
      Settings()
    }
    .ifLet(\.statistics, action: /Action.statisticsAction) {
      Statistics()
    }

  }
}

extension AppApi.Record.Detail {
  var asMoneyRecord: MoneyRecord {
    .init(
      id: id,
      date: created,
      title: title,
      notes: notes ?? "",
      type: clientRecordType,
      amount: amount,
      currencyCode: currencyCode,
      categories: categories.map { $0.asLocaleCategory }
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
  var asLocaleCategory: MoneyRecord.Category {
    .init(
      name: self.name,
      id: self.id,
      color: self.color
    )
  }
}
