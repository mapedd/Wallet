//
//  EditorFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import AppApi
import WalletCoreDataModel

public extension Currency.List {
  static var examples: [Currency.List] {
    [
      .usd,
      .pln
    ]
  }
}

extension Currency.List: Identifiable {
  public var id: String {
    code
  }
}

extension AppApi.Currency.List {
  static var preview: AppApi.Currency.List {
    .init(
      code: "USD",
      name: "Dollar",
      namePlural: "Dollars",
      symbol: "$",
      symbolNative: "$"
    )
  }
}

public struct Editor: ReducerProtocol {

  public init() {}
  
  public struct State: Equatable {
    public init(
      text: String = "New Record title",
      amount: String = "0.00",
      currency: Currency.List,
      recordType: MoneyRecord.RecordType = MoneyRecord.RecordType.expense,
      category: MoneyRecord.Category? = nil,
      addButtonDisabled: Bool = true,
      categories: [MoneyRecord.Category] = []
    ) {
      self.text = text
      self.amount = amount
      self.currency = currency
      self.recordType = recordType
      self.category = category
      self.addButtonDisabled = addButtonDisabled
      self.categories = categories
    }

    @BindingState public var text = "New Record title"
    @BindingState public var amount = "0.00"
    @BindingState public var currency: AppApi.Currency.List
    @BindingState public var recordType = MoneyRecord.RecordType.expense
    @BindingState public var category: MoneyRecord.Category? = nil
    public var addButtonDisabled = true
    public var categories: [MoneyRecord.Category] = []
    
    public static let preview = Self.init(
      text: "Buying groceries",
      amount: "123.00",
      currency: .preview,
      recordType: .expense,
      category: nil,
      addButtonDisabled: false,
      categories: MoneyRecord.Category.previews
    )
    
  }
  
  
  
  public enum Action:BindableAction, Equatable {
    case binding(BindingAction<State>)
    case changeRecordType(MoneyRecord.RecordType)
    case addButtonTapped
    case categoryPicked(MoneyRecord.Category?)
  }
  
  
  public var body: some ReducerProtocol<State,Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.$text):
        state.addButtonDisabled = State.addButtonDisabled(state)
        return .none
      case .binding(\.$amount):
        state.addButtonDisabled = State.addButtonDisabled(state)
        return .none
      case .addButtonTapped:
        return .none
      case let .changeRecordType(type):
        state.recordType = type
        return .none
      case let .categoryPicked(category):
        state.category = category
        return .none
      case .binding(_):
        return .none
      }
    }
  }
}

extension Editor.State {
  static func addButtonDisabled(_ state: Editor.State) -> Bool {
    state.text.isEmpty || Decimal(string: state.amount) == nil
  }
}
