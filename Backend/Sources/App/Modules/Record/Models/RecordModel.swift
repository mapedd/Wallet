//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 23/12/2022.
//


import Vapor
import Fluent


enum RecordType: String, Codable, CaseIterable  {
  case income
  case expense
}

enum Currency: String, Codable {
  case usd = "usd"
  case pln = "pln"
}

final class RecordModel: DatabaseModelInterface {
  typealias Module = RecordModule
  
  struct FieldKeys {
    struct v1 {
      static var amount: FieldKey { "value" }
      static var type: FieldKey { "type" }
      static var currency: FieldKey { "currency" }
      static var title: FieldKey { "title" }
      static var notes: FieldKey { "notes" }
//      static var categoryID: FieldKey { "category_id" }
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
  var currency: Currency
  
  @Field(key: FieldKeys.v1.title)
  var title: String
  
  @Field(key: FieldKeys.v1.notes)
  var notes: String?
  
//  @Field(key: FieldKeys.v1.categoryID)
//  var category: RecordCategoryModel
  
  @Field(key: FieldKeys.v1.created)
  var created: Date
  
  @Field(key: FieldKeys.v1.updated)
  var updated: Date
  
  @Field(key: FieldKeys.v1.deleted)
  var deleted: Date?
  
  @Parent(key: FieldKeys.v1.userID)
  var user: UserAccountModel
  
  init() { }
  
  init(
    id: UUID,
    amount: Decimal,
    type: RecordType,
    currency: Currency,
    title: String,
    notes: String? = nil,
//    categoryID: UUID,
    created: Date,
    updated: Date,
    deleted: Date? = nil,
    userID: UUID
  ) {
    self.id = id
    self.amount = amount
    self.type = type
    self.currency = currency
    self.title = title
    self.notes = notes
//    self.$category.id = categoryID
    self.created = created
    self.updated = updated
    self.deleted = deleted
    self.$user.id = userID
  }
}
//
//
//// a pivot model for many-to-many reletionship.
//final class RecordToCategoryPivot: Model {
//    static let schema = "record+category"
//
//    @ID(key: .id)
//    var id: UUID?
//
//    @Parent(key: "record_id")
//    var record: RecordModel
//
//    @Parent(key: "category_id")
//    var category: RecordCategoryModel
//
//    init() { }
//
//    init(
//      id: UUID? = nil,
//      record: RecordModel,
//      category: RecordCategoryModel
//    ) throws {
//        self.id = id
//        self.$record.id = try record.requireID()
//        self.$category.id = try category.requireID()
//    }
//}
