//
//  EmailConfirmationToken.swift
//  
//
//  Created by Tomek Kuzma on 28/02/2023.
//

import Vapor
import Fluent

final class EmailConfirmationToken: DatabaseModelInterface {
  typealias Module = UserModule
  
  struct FieldKeys {
    struct v1 {
      static var email: FieldKey { "email" }
      static var created: FieldKey { "created" }
      static var confirmed: FieldKey { "confirmed" }
      static var userId: FieldKey { "user_id" }
    }
  }
  
  @ID()
  var id: UUID?
  
  @Field(key: FieldKeys.v1.email)
  var email: String
  
  @Timestamp(key: FieldKeys.v1.created, on: .create, format: .iso8601)
  var created: Date?
  
  @Parent(key: FieldKeys.v1.userId)
  var user: UserAccountModel
  
  init() { }
  
  init(
    id: UUID? = nil
  ) {
    self.id = id
  }
}
