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
    var id: UUID {
        record.id
    }
}

enum RecordAction: Equatable {
   case deleteItem
}

struct RecordEnvironment {

}


let recordReducer = Reducer<
    RecordState,
    RecordAction,
    RecordEnvironment>
{ state, action, _ in
    return .none
}

struct RecordView: View {
    var store: Store<RecordState, RecordAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Text(viewStore.record.formattedCopy)
                .foregroundColor(viewStore.record.type == .income ? .green : .red)
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
                reducer: recordReducer,
                environment: RecordEnvironment()
            )
        )
    }
}
