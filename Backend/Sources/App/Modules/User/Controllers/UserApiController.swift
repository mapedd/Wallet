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


func generateTokenString() -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789="
  let tokenValue = String((0..<64).map { _ in letters.randomElement()! })
  return tokenValue
}

struct UserApiController {
  
  func signInApi(req: Request) async throws -> User.Token.Detail {
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.unauthorized)
    }
    
    let token = UserTokenModel(value: generateTokenString(), userId: user.id)
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
    
    guard let bearer =  req.headers.bearerAuthorization else {
      throw Abort(.unauthorized)
    }
    
    let token = try await UserTokenModel
      .query(on: req.db)
      .filter(\.$value == bearer.token)
      .first()
    
    
    guard
      let token
    else {
      throw Abort(.unauthorized)
    }
    
    
    let user = try await token.$user.get(on: req.db)
    
    guard let userId = token.user.id else {
      throw Abort(.unauthorized)
    }
    
    try await token.delete(on: req.db)
    
    let newToken = UserTokenModel(
      value: generateTokenString(),
      userId: userId
    )
    
    try await newToken.create(on: req.db)
    let userDetail = User.Account.Detail(
      id: userId,
      email: token.user.email
    )
    
    return User
      .Token
      .Detail(
        id: newToken.id!,
        value: newToken.value,
        user: userDetail
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
