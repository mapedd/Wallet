//
//  RecordListView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
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

struct RecordView: View {
    var store: Store<RecordState, RecordAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Text(viewStore.record.formattedCopy)
                    .foregroundColor(viewStore.record.type == .income ? .green : .red)
                Button("Category",
                       action: {
                  viewStore.send(.showCategoryPickerTapped)
                })
            }
            .onTapGesture {
              viewStore.send(.setSheet(isPresented: true))
            }
            .sheet(
              isPresented: viewStore.binding(
                get: \.isSheetPresented,
                send: RecordAction.setSheet(isPresented:)
              )
            ) {
              IfLetStore(
                self.store.scope(
                  state: \.details,
                  action: RecordAction.detailsAction
                )
              ) {
                RecordDetailsView(store: $0)
              } else: {
                ProgressView()
              }
            }
        }
    }
}

let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.currencyCode = "USD"
    formatter.numberStyle = .currency
    return formatter
}()

extension MoneyRecord {
    var formattedCopy : String {
        "\(formatter.string(for: amount) ?? "") - \(title)"
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(
            store: .init(
                initialState: .init(
                    record: .init(
                        id: .init(),
                        date: .init(),
                        title: "Record",
                        type: .expense,
                        amount: Decimal(123),
                        currency: .usd
                    )
                ),
                reducer: combinedRecordReducer,
                environment: RecordEnvironment()
            )
        )
    }
}
