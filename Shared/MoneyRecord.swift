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
  var type: RecordType
  var amount: Decimal
  var currency: Currency
  var category: Category?
  
  static var preview: MoneyRecord {
    .init(
      id: .init(),
      date: .init(),
      title: "Record",
      type: .expense,
      amount: Decimal(123),
      currency: .pln
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

let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.currencyCode = "USD"
    formatter.numberStyle = .currency
    return formatter
}()

extension Decimal {
  var formattedDecimalValue: String {
    formatter.string(for: self) ?? ""
  }
}

extension MoneyRecord {
    var formattedCopy : String {
      "\(amount.formattedDecimalValue) - \(title)"
    }
}

enum Currency: String, Equatable {
  case pln
  case usd
  case eur
  case gbp
}
