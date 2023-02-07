//
//  RecordFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import AppApi

public struct Record : ReducerProtocol {
  
  public init() {}

  public struct State: Equatable, Identifiable {
    public init(
      record: MoneyRecord,
      details: RecordDetails.State? = nil
    ) {
      self.record = record
      self.details = details
    }


    public var record: MoneyRecord
    public var details: RecordDetails.State?
    
    public var id: UUID {
      record.id
    }
    public var isSheetPresented: Bool {
      details != nil
    }
  }
  
  public enum Action {
    case showCategoryPickerTapped
    case setSheet(isPresented:Bool)
    case detailsAction(RecordDetails.Action)
  }
  
  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .setSheet(isPresented: true):
        state.details = .init(
          record: state.record
        )
        return .none
      case .setSheet(isPresented: false):
        if let updatedRecord = state.details?.record {
          state.record = updatedRecord
        }
        state.details = nil
        return .none

      case .detailsAction(let recordDetailsAction) :
        if case .deleteRecordTapped = recordDetailsAction {
          state.details = nil
        }
        if case .hideDetails = recordDetailsAction {
          state.details = nil
        }
        return .none
      default:
        return .none
      }
    }
    .ifLet(\.details, action: /Action.detailsAction) {
      RecordDetails()
    }
  }
}

extension Record.State {
  public static var sample: [Record.State] = [
    Record.State(
      record: .init(
        id: .init(),
        date: .init(),
        title: "sample expense today",
        notes: "",
        type: .expense,
        amount: Decimal(123),
        currencyCode: "EUR",
        categories: [.init(name: "Food", id: .init(), color: 1)]
      )
    ),
    Record.State(
      record: .init(
        id: .init(),
        date: .init(),
        title: "sample income today",
        notes: "",
        type: .income,
        amount: Decimal(222),
        currencyCode: "EUR",
        categories: [.init(name: "Food", id: .init(), color: 1)]
      )
    ),
    Record.State(
      record: .init(
        id: .init(),
        date: .init().addingTimeInterval(-60 * 60 * 24 * 3),
        title: "sample income 3 days ago",
        notes: "",
        type: .income,
        amount: Decimal(9.99),
        currencyCode: "EUR",
        categories: [.init(name: "Food", id: .init(), color: 1)]
      )
    ),
    Record.State(
      record: .init(
        id: .init(),
        date: .init().addingTimeInterval(-60 * 60 * 24 * 30),
        title: "sample income month ago",
        notes: "",
        type: .income,
        amount: Decimal(44.2),
        currencyCode: "EUR",
        categories: [.init(name: "Food", id: .init(), color: 1)]
      )
    )
  ]
}

extension AppApi.Currency.List {
  public static var eur = AppApi.Currency.List(
    code: "EUR",
    name: "Euro",
    namePlural: "Euros",
    symbol: "€",
    symbolNative: "€"
  )
  public static var usd = AppApi.Currency.List(
    code: "USD",
    name: "Dollar",
    namePlural: "Dollars",
    symbol: "$",
    symbolNative: "$"
  )
  public static var pln = AppApi.Currency.List(
    code: "PLN",
    name: "Polish Zloty",
    namePlural: "Polish Zlotys",
    symbol: "PLN",
    symbolNative: "zł"
  )
}