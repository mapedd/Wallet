//
//  MoneyRecord.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import LinuxHelpers

public struct MoneyRecord: Equatable, Identifiable {
  
  public init(
    id: UUID,
    date: Date,
    title: String,
    notes: String,
    type: MoneyRecord.RecordType,
    amount: Decimal,
    currencyCode: String,
    categories: [MoneyRecord.Category]
  ) {
    self.id = id
    self.date = date
    self.title = title
    self.notes = notes
    self.type = type
    self.amount = amount
    self.currencyCode = currencyCode
    self.categories = categories
  }
  
  public enum RecordType: Equatable {
    case income
    case expense
  }
  public var id: UUID
  public var date: Date
  public var title: String
  public var notes: String
  public var type: RecordType
  public var amount: Decimal
  public var currencyCode: String
  public var categories: [MoneyRecord.Category]
  
  public static var preview: MoneyRecord {
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

extension MoneyRecord {
  
  public struct Category: Hashable, Identifiable {
    
    public init(
      name: String,
      id: UUID,
      color: Int
    ) {
      self.name = name
      self.id = id
      self.color = color
    }
    
    
    public var name: String
    public var id: UUID
    public var color: Int
    
    public static var previews = [
      Category(name: "Food", id: .init(), color: 1),
      Category(name: "Car", id: .init(), color: 3),
      Category(name: "Kids", id: .init(), color: 2),
    ]
  }
}

public extension MoneyRecord {
  var formattedCopy : String {
    "\(amount.formatted(currency: currencyCode)) - \(title)"
  }
}

