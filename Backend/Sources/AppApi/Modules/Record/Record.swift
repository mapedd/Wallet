//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 28/12/2022.
//

import Foundation

public enum RecordType: String, Codable, CaseIterable  {
  case income
  case expense
}

public enum Currency: String, Codable {
  case usd = "usd"
  case pln = "pln"
}

public enum Record {}

public extension Record {
  struct Detail: Codable,Hashable {
    
    public init(
      id: UUID,
      title: String,
      amount: Decimal,
      type: RecordType,
      currency: Currency,
      notes: String? = nil,
      created: Date,
      updated: Date,
      deleted: Date? = nil
    ) {
      self.id = id
      self.title = title
      self.amount = amount
      self.type = type
      self.currency = currency
      self.notes = notes
      self.created = created
      self.updated = updated
      self.deleted = deleted
    }
    
    public var id: UUID
    public var title: String
    public var amount: Decimal
    public var type: RecordType
    public var currency: Currency
    public var notes: String?
    public var created: Date
    public var updated: Date
    public var deleted: Date?
  }
  
  struct Update: Codable,Hashable {
    
    public init(
      id: UUID,
      title: String? = nil,
      amount: Decimal? = nil,
      type: RecordType? = .expense,
      currency: Currency? = nil,
      notes: String? = nil,
      updated: Date,
      deleted: Date? = nil
    ) {
      self.id = id
      self.title = title
      self.amount = amount
      self.type = type
      self.currency = currency
      self.notes = notes
      self.updated = updated
      self.deleted = deleted
    }
    
    public var id: UUID
    public var title: String?
    public var amount: Decimal?
    public var type: RecordType?
    public var currency: Currency?
    public var notes: String?
    public var updated: Date
    public var deleted: Date?
  }
}
