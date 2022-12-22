//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 01. 07..
//

import Vapor
import Fluent

public struct DateProvider {
  public init(
    currentDate: @escaping () -> Date
  ) {
    self.currentDate = currentDate
  }
  public var currentDate: () -> Date
  public var now: Date {
    currentDate()
  }
  
  public var tokenExpiryDate: Date {
    .now.addingTimeInterval(60)
  }
}

struct UserTokenAuthenticator: AsyncBearerAuthenticator {
  
  var dateProvider: DateProvider
  init(
    dateProvider: DateProvider
  ) {
    self.dateProvider = dateProvider
  }
  
  func authenticate(bearer: BearerAuthorization, for req: Request) async throws {
    guard
      let token = try await UserTokenModel
        .query(on: req.db)
        .filter(\.$value == bearer.token)
        .first()
    else {
      return
    }
    
    // check if token not expired
    guard token.expiry > dateProvider.now else {
      return
    }
    
    guard
      let user = try await UserAccountModel
        .find(token.$user.id, on: req.db)
    else {
      return
    }
    req.auth.login(AuthenticatedUser(id: user.id!, email: user.email))
  }
}
