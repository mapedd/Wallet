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
    
    let token = EmailConfirmationToken()
    token.$user.id = user.id!
    token.email = login.email
    
    do {
      try await token.create(on: req.db)
    } catch {
      req.logger.error("error creating registration token \(error)")
      throw Abort(.internalServerError)
    }
    
//    let domain = "portfelmapedd.online"
    let domain = "localhost:8080"
    let domainSender = "portfelmapedd.online"
    let productName = "Wallet"
    
    
    let registerLink = "http://www.\(domain)/\(UserRouter.Route.confirmPassword.pathComponent)?token=\(try! token.requireID().uuidString)"
    
    req.logger.notice("registered user, generating confirm link: \(registerLink)")
    
    let query = MailerSendEmail.Request(
      from: .init(
        email: "welcome@\(domainSender)",
        name: "Tomek"
      ),
      to: [
        .init(
          email: login.email,
          name: "New user"
        )
      ],
      subject: "Welcome to \(productName)!",
      text: "",
      html:  """
        <p>You've requested to register your account. <a
        href="\(registerLink)">
        Click here</a> to confirm your email.
        It's valid for only 30 minutes</p>
        """
    )
    
    let apiKey = req.application.environment.mailerSendApiKey
    try await req.sendRegistrationEmail(query: query, apiKey: apiKey)
    
    req.logger.notice("sent email confirmation from \(query.from.email) to \(query.to.first!.email)")
    
    return User.Account.Detail.init(
      id: user.id!,
      email: user.email
    )
  }
  
  func resetPassword(_ req: Request) async throws -> ActionResult {
    return .init(success: true)
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

enum MailerSendEmail {
  struct Request: Content, Codable {
    struct Address: Content, Codable {
      let email: String
      let name: String
    }
    let from: Address
    let to: [Address]
    
    let subject: String
    let text: String
    let html: String
  }
  
  struct Response: Content, Codable {
    
  }
  
  struct ValidationError: Codable, Swift.Error {
    let message: String
    let errors: [String: [String]]
    
    var localizedDescription: String {
      message
    }
  }
}

extension Request {
  func sendRegistrationEmail(
    query: MailerSendEmail.Request,
    apiKey: String
  ) async throws  {
        
    let url: URI = "https://api.mailersend.com/v1/email"
    
    let response = try await client.post(url) { req in
        try req.query.encode(query)
        req.headers.add(name: "Authorization", value: "Bearer \(apiKey)")
    }
        
    do {
      let validationError = try response.content.decode(MailerSendEmail.ValidationError.self)
      
      throw validationError
    } catch { }
    
    if
      response.status != .accepted &&
      response.status != .ok
    {
      logger.error("error sending email \(response.status)")
      throw Abort(.internalServerError)
    }
  }
}
