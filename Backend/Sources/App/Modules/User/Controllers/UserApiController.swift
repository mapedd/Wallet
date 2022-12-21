//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 01. 07..
//

import Vapor
import FluentKit

extension User.Token.Detail: Content {}
extension User.Account.Detail: Content {}
extension ActionResult: Content {}


struct UserApiController {
  
  func signInApi(req: Request) async throws -> User.Token.Detail {
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.unauthorized)
    }
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789="
    let tokenValue = String((0..<64).map { _ in letters.randomElement()! })
    let token = UserTokenModel(value: tokenValue, userId: user.id)
    try await token.create(on: req.db)
    let userDetail = User.Account.Detail(id: user.id, email: user.email)
    
    return User
      .Token
      .Detail(
        id: token.id!,
        value: token.value,
        user: userDetail
      )
  }
  
  func listAll(req: Request) async throws -> [User.Account.Detail] {
    let users = try await UserAccountModel
      .query(on: req.db)
      .all()
    
    return users.map {
      .init(
        id: $0.id!,
        email: $0.email
      )
    }
  }
  
  func refresh(req: Request) async throws -> User.Token.Detail{
    return User
      .Token
      .Detail(
        id: .init(),
        value: "123",
        user: .init(id: .init(), email: "")
      )
  }
  
  func signOut(req: Request) async throws -> ActionResult {
    guard let bearer =  req.headers.bearerAuthorization else {
      throw Abort(.unauthorized)
    }
    
    let token = try await UserTokenModel
      .query(on: req.db)
      .filter(\.$value == bearer.token)
      .first()
    
    guard let token else {
      throw Abort(.unauthorized)
    }
    
    try await token.delete(on: req.db)
    
    req.auth.logout(AuthenticatedUser.self)
    req.session.unauthenticate(AuthenticatedUser.self)
    
    return ActionResult(success: true)
  }
  
  func register(req: Request) async throws -> User.Account.Detail {
    let login = try req.content.decode(User.Account.Login.self)
    
    let user = UserAccountModel(
      email: login.email,
      password: try Bcrypt.hash(login.password)
    )
    try await user.create(on: req.db)
    
    return User.Account.Detail.init(
      id: user.id!,
      email: user.email
    )
  }
}
