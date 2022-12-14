//
//  RecordFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct Record : ReducerProtocol {
  struct State: Equatable, Identifiable {
    var record: MoneyRecord
    var details: RecordDetails.State?
    var id: UUID {
      record.id
    }
    var isSheetPresented: Bool {
      details != nil
    }
  }
  
  enum Action {
    case showCategoryPickerTapped
    case setSheet(isPresented:Bool)
    case detailsAction(RecordDetails.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .setSheet(isPresented: true):
        state.details = .init(record: state.record)
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
  static var sample: [Record.State] = [
    Record.State(
      record: .init(
        id: .init(),
        date: .init(),
        title: "sample expense today",
        notes: "",
        type: .expense,
        amount: Decimal(123),
        currency: .eur,
        category: .init(name: "Food", id: .init())
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
        currency: .eur
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
        currency: .eur,
        category: .init(name: "Entertainment", id: .init())
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
        currency: .eur
      )
    )
  ]
}
