//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 23/12/2022.
//


import Vapor
import Fluent

final class RecordModel: DatabaseModelInterface {
  typealias Module = RecordModule
  
  struct FieldKeys {
    struct v1 {
      static var amount: FieldKey { "value" }
      static var type: FieldKey { "type" }
      static var currency: FieldKey { "currency" }
      static var title: FieldKey { "title" }
      static var notes: FieldKey { "notes" }
      static var created: FieldKey { "created" }
      static var deleted: FieldKey { "deleted" }
      static var updated: FieldKey { "updated" }
      static var userID: FieldKey { "user_id" }
    }
  }
  
  @ID()
  var id: UUID?
  
  @Field(key: FieldKeys.v1.amount)
  var amount: Decimal
  
  @Enum(key: FieldKeys.v1.type)
  var type: RecordType
  
  @Field(key: FieldKeys.v1.currency)
  var currencyCode: String
  
  @Field(key: FieldKeys.v1.title)
  var title: String
  
  @Field(key: FieldKeys.v1.notes)
  var notes: String?
  
  @Siblings(through: RecordToCategoryPivot.self, from: \.$record, to: \.$category)
  var categories: [RecordCategoryModel]
  
  @Timestamp(key: FieldKeys.v1.created, on: .create, format: .iso8601)
  var created: Date?
  
  @Timestamp(key: FieldKeys.v1.updated, on: .update, format: .iso8601)
  var updated: Date?
  
  @Timestamp(key: FieldKeys.v1.deleted, on: .delete, format: .iso8601)
  var deleted: Date?
  
  @Parent(key: FieldKeys.v1.userID)
  var user: UserAccountModel
  
  init() { }
  
  init(
    id: UUID,
    amount: Decimal,
    type: RecordType,
    currencyCode: Currency.Code,
    title: String,
    notes: String? = nil,
    created: Date,
    updated: Date,
    deleted: Date? = nil,
    userID: UUID
  ) {
    self.id = id
    self.amount = amount
    self.type = type 
    self.currencyCode = currencyCode
    self.title = title
    self.notes = notes
    self.created = created
    self.updated = updated
    self.deleted = deleted
    self.$user.id = userID
  }
}
