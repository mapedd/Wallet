//
//  RecordFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

struct RecordState: Equatable, Identifiable {
    var record: MoneyRecord
    var details: RecordDetailsState?
    var id: UUID {
        record.id
    }
  var isSheetPresented: Bool {
    details != nil
  }

}

enum RecordAction {
    case deleteItem
    case showCategoryPickerTapped
    case setSheet(isPresented:Bool)
    case detailsAction(RecordDetailsAction)
}

struct RecordEnvironment {

}


let recordReducer = Reducer<
    RecordState,
    RecordAction,
    RecordEnvironment>
{ state, action, _ in
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
  default:
    return .none
  }
}

let combinedRecordReducer = recordDetailsReducer
  .optional()
  .pullback(
    state: \.details,
    action: /RecordAction.detailsAction,
    environment: { _ in RecordDetailsEnvironment() }
  )
  .combined(with: recordReducer)
