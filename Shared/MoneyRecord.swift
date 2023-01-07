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
  var currency: Currency
  var category: Category?
  
  static var preview: MoneyRecord {
    .init(
      id: .init(),
      date: .init(),
      title: "Record",
      notes: "Sample notes",
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
//
//let formatter: NumberFormatter = {
//    let formatter = NumberFormatter()
//    formatter.maximumFractionDigits = 2
//    formatter.minimumFractionDigits = 2
//    formatter.currencyCode = "USD"
//    formatter.numberStyle = .currency
//    return formatter
//}()
//
//extension Decimal {
//  var formattedDecimalValue: String {
//    formatter.string(for: self) ?? ""
//  }
//}

extension MoneyRecord {
    var formattedCopy : String {
      "\(amount.formatted(.currency(code: currency.rawValue))) - \(title)"
    }
}

enum Currency: String, Equatable, CaseIterable, Identifiable {
  var id: String {
    return self.rawValue
  }
  case pln
  case usd
  case eur
  case gbp
  
  var symbol: String {
    getSymbol(forCurrencyCode: self.rawValue) ?? rawValue
  }
}


func getSymbol(forCurrencyCode code: String) -> String? {
   let locale = NSLocale(localeIdentifier: code)
  return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
}
