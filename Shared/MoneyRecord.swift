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
  var categories: [Category]
  
  static var preview: MoneyRecord {
    .init(
      id: .init(),
      date: .init(),
      title: "Record",
      notes: "Sample notes",
      type: .expense,
      amount: Decimal(123),
      currencyCode: "usd",
      categories: [.init(name: "Sweets", id: UUID(), color: 1)]
    )
  }
}

struct Category: Hashable, Identifiable {
  var name: String
  var id: UUID
  var color: Int

  static var previews = [
    Category(name: "Food", id: .init(), color: 1),
    Category(name: "Car", id: .init(), color: 3),
    Category(name: "Kids", id: .init(), color: 2),
  ]
}

extension MoneyRecord {
    var formattedCopy : String {
      "\(amount.formatted(.currency(code: currencyCode))) - \(title)"
    }
}
