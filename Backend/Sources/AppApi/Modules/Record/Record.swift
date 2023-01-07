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


public enum Record {}

public extension Record {
  struct Detail: Codable,Hashable {
    
    public var id: UUID
    public var title: String
    public var amount: Decimal
    public var type: RecordType
    public var currencyCode: Currency.Code
    public var notes: String?
    public var categories: [RecordCategory.Detail]
    public var created: Date
    public var updated: Date
    public var deleted: Date?
    
    public init(
      id: UUID,
      title: String,
      amount: Decimal,
      type: RecordType,
      currencyCode: Currency.Code,
      notes: String? = nil,
      categories: [RecordCategory.Detail] = [],
      created: Date,
      updated: Date,
      deleted: Date? = nil
    ) {
      self.id = id
      self.title = title
      self.amount = amount
      self.type = type
      self.currencyCode = currencyCode
      self.notes = notes
      self.categories = categories
      self.created = created
      self.updated = updated
      self.deleted = deleted
    }
    
  }
  
  struct Update: Codable,Hashable {
    
    public var id: UUID
    public var title: String?
    public var amount: Decimal?
    public var type: RecordType?
    public var currencyCode: Currency.Code?
    public var notes: String?
    public var categoryIds: [UUID]
    public var updated: Date
    public var deleted: Date?
    
    public init(
      id: UUID,
      title: String? = nil,
      amount: Decimal? = nil,
      type: RecordType? = .expense,
      currencyCode: Currency.Code? = nil,
      notes: String? = nil,
      categoryIds: [UUID]? = nil,
      updated: Date,
      deleted: Date? = nil
    ) {
      self.id = id
      self.title = title
      self.amount = amount
      self.type = type
      self.currencyCode = currencyCode
      self.notes = notes
      self.categoryIds = categoryIds ?? []
      self.updated = updated
      self.deleted = deleted
    }
  }
}
