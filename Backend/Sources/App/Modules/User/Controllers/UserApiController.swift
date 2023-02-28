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

struct UserQuery: Codable, Content {
  var userId: UUID
}

struct EchoResponse: Codable, Content {
  var hello = "nice to meet your"
  var date = Date()
}


func generateTokenString() -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789="
  let tokenValue = String((0..<64).map { _ in letters.randomElement()! })
  return tokenValue
}

extension UserTokenModel {
  convenience init(userId: UUID, dateProvider: DateProvider) {
    self.init(
      value: generateTokenString(),
      expiry: dateProvider.tokenExpiryDate,
      refresh: generateTokenString(),
      userId: userId
    )
  }
}

struct UserApiController {
  
  var dateProvider: DateProvider
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
  }
  
  func signInApi(req: Request) async throws -> User.Token.Detail {
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.notFound)
    }
    
    let token = UserTokenModel(
      userId: user.id,
      dateProvider: dateProvider
    )
    try await token.create(on: req.db)
    
    
    return User
      .Token
      .Detail(
        id: token.id!,
        token: .init(
          value: token.value,
          expiry: token.expiry,
          refresh: token.refresh
        ),
        user: .init(
          id: user.id,
          email: user.email
        )
      )
  }
  
  func details(req: Request) async throws -> User.Account.Detail {
    
    let userQuery = try req.query.decode(UserQuery.self)
    
    guard
      let user = try await UserAccountModel
        .query(on: req.db)
        .filter(\.$id == userQuery.userId)
        .first()
    else {
      throw Abort(.notFound)
    }
    
    return .init(
      id: user.id!,
      email: user.email
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
  
  func any(req: Request) async throws -> EchoResponse {
    return EchoResponse()
  }
  
  func refresh(req: Request) async throws -> User.Token.Detail{
    
    guard let bearer =  req.headers.bearerAuthorization else {
      throw Abort(.unauthorized)
    }
    
    let input = try req.content.decode(User.Token.Refresh.self)
    
    let token = try await UserTokenModel
      .query(on: req.db)
      .filter(\.$value == bearer.token)
      .first()
    
    guard
      let token,
      token.refresh == input.refresh
    else {
      throw Abort(.unauthorized)
    }
    
    let user = try await token.$user.get(on: req.db)
    
    try await token.delete(on: req.db)
    
    let newToken = UserTokenModel(
      userId: user.id!,
      dateProvider: dateProvider
    )
    
    try await newToken.create(on: req.db)
    
    let userDetail = User.Account.Detail(
      id: user.id!,
      email: user.email
    )
    
    return User
      .Token
      .Detail(
        id: newToken.id!,
        token: .init(
          value: newToken.value,
          expiry: newToken.expiry,
          refresh: newToken.refresh
        ),
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
  
  func remindPassword(req: Request) async throws -> ActionResult {
    return ActionResult(success: true)
  }
  
  func send(to email: String) async throws -> Bool {
//    let sendOptions = SimpleSendEmailOptions(
//      senderId: UUID(),
//      to: email,
//      body: "hello",
//      subject: "welcome"
//    )
    
//   try await(
//    CommonActionsControllerAPI.sendEmailSimpleWithRequestBuilder(simpleSendEmailOptions: sendOptions)
//       .addHeader(name: "x-api-key", value: "d1575fc277bd18c02537cd1adb2c41a1608c346848e1c85c6970fb8d229a5d35")
//       .execute()
//       .done { response in
//         // handle success
//       }
//       .catch(policy: .allErrors) { err in
//         // handle error
//         guard let e = err as? mailslurp.ErrorResponse else {
//             print(err.localizedDescription)
//             return
//         }
//         // pattern match the error to access status code and data
//         // MailSlurp returns 4xx errors when invalid parameters or
//         // unsatisfiable request. See the message and status code
//         switch e {
//         case .error(let statusCode, let data, _, _):
//             let msg = String(decoding: data!, as: UTF8.self)
//             let error = "\(statusCode) Bad request: \(msg)"
//            print(error)
//         }
//   )
    
    return true
  }
  
  func register(req: Request) async throws -> User.Account.Detail {
    let login = try req.content.decode(User.Account.Login.self)
    
    guard checkValid(email: login.email) else {
      throw Abort(.badRequest, reason: "invalid email")
    }
    
    let user = UserAccountModel(
      email: login.email,
      password: try Bcrypt.hash(login.password)
    )
    do {
      try await user.create(on: req.db)
    } catch {
      req.logger.error("error creating user \(error)")
      throw Abort(.conflict,reason: "user with this email already exists")
    }
    
//    let email = SendGridEmail(
//      personalizations: nil,
//      from: .init(email: login.email),
//      replyTo: nil,
//      subject: "Welcome, confirm your email",
//      content: [["text/plain" : "Welcome, click here to confirm your email"]],
//      attachments: nil,
//      templateId: nil,
//      sections: nil,
//      headers: [:],
//      categories: [],
//      customArgs: [:],
//      sendAt: .now,
//      batchId: UUID().uuidString,
//      asm: nil,
//      ipPoolName: "",
//      mailSettings: .init(),
//      trackingSettings: .init()
//    )
//
//    let _ = try await req
//      .application
//      .sendgrid
//      .client
//      .send(emails: [email], on: req.eventLoop)
//      .get()
    
    try await send(to: login.email)
    
    return User.Account.Detail.init(
      id: user.id!,
      email: user.email
    )
  }
  
  func checkValid(email: String) -> Bool {
    do {
      let emailRegex = try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive)
      let textRange = NSRange(location: 0, length: email.count)
      if emailRegex.firstMatch(in: email, options: [], range: textRange) != nil {
        return true
      } else {
        return false
      }
    } catch  {
      return false
    }
  }
}
