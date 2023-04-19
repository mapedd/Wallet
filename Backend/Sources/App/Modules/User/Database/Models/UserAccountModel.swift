//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor
import Fluent

final class UserAccountModel: DatabaseModelInterface {
  typealias Module = UserModule
  
  struct FieldKeys {
    struct v1 {
      static var email: FieldKey { "email" }
      static var password: FieldKey { "password" }
      static var created: FieldKey { "created" }
      static var updated: FieldKey { "updated" }
      static var deleted: FieldKey { "deleted" }
      static var emailConfirmed: FieldKey { "email_confirmed" }
    }
  }
  
  @ID() var id: UUID?
  
  @Field(key: FieldKeys.v1.email)
  var email: String
  
  @Field(key: FieldKeys.v1.password)
  var password: String
  
  @Timestamp(key: FieldKeys.v1.created, on: .create, format: .iso8601)
  var created: Date?
  
  @Timestamp(key: FieldKeys.v1.updated, on: .update, format: .iso8601)
  var updated: Date?
  
  @Timestamp(key: FieldKeys.v1.deleted, on: .delete, format: .iso8601)
  var deleted: Date?
  
  @Field(key: FieldKeys.v1.emailConfirmed)
  var emailConfirmed: Date?
  
  @Children(for: \.$user)
  var records: [RecordModel]
  
  init() { }
  
  init(
    id: UUID? = nil,
    email: String,
    password: String
  ) {
    self.id = id
    self.email = email
    self.password = password
  }
}
