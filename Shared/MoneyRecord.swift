//
//  MoneyRecord.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation

struct MoneyRecord: Equatable, Identifiable {
  enum RecordType: Equatable {
    case income
    case expense
  }
  var id: UUID
  var date: Date
  var title: String
  var notes: String
  var type: RecordType
  var amount: Decimal
  var currencyCode: String
  var category: Category?
  
  static var preview: MoneyRecord {
    .init(
      id: .init(),
      date: .init(),
      title: "Record",
      notes: "Sample notes",
      type: .expense,
      amount: Decimal(123),
      currencyCode: "usd"
    )
  }
}

struct Category: Hashable, Identifiable {
  var name: String
  var id: UUID

  static var previews = [
    Category(name: "Food", id: .init()),
    Category(name: "Car", id: .init()),
    Category(name: "Kids", id: .init()),
  ]
}

extension MoneyRecord {
    var formattedCopy : String {
      "\(amount.formatted(.currency(code: currencyCode))) - \(title)"
    }
}
