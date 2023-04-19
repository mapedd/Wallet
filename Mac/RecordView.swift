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
  var record: MoneyRecord
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(record.formattedCopy)
          .foregroundColor(record.type == .income ? .green : .red)
        Spacer()
        
      }
      if !record.categories.isEmpty {
        Text(record.categories.map { $0.name}.joined(separator: ", "))
      }
    }
  }
}
  
  
  //struct RecordView_Previews: PreviewProvider {
  //  static var previews: some View {
  //    NavigationView {
  //      List {
  //        ForEach(Record.State.sample) { record in
  //          RecordView(
  //            store: .init(
  //              initialState: .init(
  //                record: .init(
  //                  id: .init(),
  //                  date: .init(),
  //                  title: "Title",
  //                  notes: "",
  //                  type: .expense,
  //                  amount: Decimal(floatLiteral: 12.1),
  //                  currencyCode: "USD",
  //                  categories: MoneyRecord.Category.previews
  //                )
  //              ),
  //              reducer: Record()
  //            )
  //          )
  //        }
  //      }
  //    }
  //  }
  //}
