//
//  RecordView.swift
//  Wallet Mac
//
//  Created by Tomasz Kuzma on 07/02/2023.
//

import SwiftUI
import ComposableArchitecture
import WalletCore

struct RecordView: View {
  var store: StoreOf<Record>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        HStack {
          Text(viewStore.record.formattedCopy)
            .foregroundColor(viewStore.record.type == .income ? .green : .red)
          Spacer()

        }
        if !viewStore.record.categories.isEmpty {
          Text(viewStore.record.categories.map { $0.name}.joined(separator: ", "))
        }
      }
      .onTapGesture {
        viewStore.send(.setSheet(isPresented: true))
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isSheetPresented,
          send: Record.Action.setSheet(isPresented:)
        )
      ) {
        IfLetStore(
          self.store.scope(
            state: \.details,
            action: Record.Action.detailsAction
          )
        ) { store in
          NavigationView {
            RecordDetailsView(store: store)
          }
        }
      }
    }
  }
}


struct RecordView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      List {
        ForEach(Record.State.sample) { record in
          RecordView(
            store: .init(
              initialState: .init(
                record: .init(
                  id: .init(),
                  date: .init(),
                  title: "Title",
                  notes: "",
                  type: .expense,
                  amount: Decimal(floatLiteral: 12.1),
                  currencyCode: "USD",
                  categories: MoneyRecord.Category.previews
                )
              ),
              reducer: Record()
            )
          )
        }
      }
    }
  }
}