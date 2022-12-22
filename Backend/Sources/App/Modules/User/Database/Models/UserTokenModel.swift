//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 01. 07..
//

import Vapor
import Fluent

final class UserTokenModel: DatabaseModelInterface {
  typealias Module = UserModule
  
  struct FieldKeys {
    struct v1 {
      static var value: FieldKey { "value" }
      static var expiry: FieldKey { "expiry" }
      static var refresh: FieldKey { "refresh" }
      static var userId: FieldKey { "user_id" }
    }
  }
  
  @ID() var id: UUID?
  @Field(key: FieldKeys.v1.value) var value: String
  @Field(key: FieldKeys.v1.expiry) var expiry: Date
  @Field(key: FieldKeys.v1.refresh) var refresh: String
  @Parent(key: FieldKeys.v1.userId) var user: UserAccountModel
  
  init() { }
  
  init(
    id: UUID? = nil,
    value: String,
    expiry: Date,
    refresh: String,
    userId: UUID)
  {
    self.id = id
    self.value = value
    self.expiry = expiry
    self.refresh = refresh
    self.$user.id = userId
  }
}
