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

enum Currency: String, Equatable {
  case pln
  case usd
  case eur
  case gbp
}
