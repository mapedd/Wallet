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
  
  func requestAccountDeletion(req: Request) async throws -> ActionResult {
    
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.unauthorized)
    }
    
    let token = DeleteAccountToken()
    token.$user.id = user.id
    
    do {
      try await token.create(on: req.db)
    } catch {
      req.logger.error("error creating registration token \(error)")
      throw Abort(.internalServerError)
    }
    
    try await sendAccountDeletionEmail(req, email: user.email, token: token)
    
    return ActionResult(success: true)
  }
  
  struct EmailConfirmationResend: Codable {
    var email: String
  }
  
  func resendEmailConfirmationEmail(req: Request) async throws -> ActionResult {
    let query = try req.query.decode(EmailConfirmationResend.self)
    guard let email = query.email.removingPercentEncoding else {
      throw Abort(.notFound)
    }
    let user = try await UserAccountModel
      .query(on: req.db)
      .filter(\.$email == email)
      .first()
    
     guard let user else {
      throw Abort(.notFound)
    }
    
    let token = EmailConfirmationToken()
    token.$user.id = user.id!
    token.email = user.email
    
    do {
      try await token.create(on: req.db)
    } catch {
      req.logger.error("error creating registration token \(error)")
      throw Abort(.internalServerError)
    }
    
    try await sendConfirmationEmail(req, email: user.email, token: token)
    
    return .init(success: true)
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
    
    try await sendConfirmationEmail(req, email: login.email, token: token)
    
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
  
  private func sendAccountDeletionEmail(_ req: Request, email: String, token: DeleteAccountToken) async throws {
    
    let tokenId = try token.requireID().uuidString
    
    let query = Email.deleteAccountRequest(
      tokenId: tokenId,
      email: email,
      logger: req.logger
    )
    
    try await req.sendEmail(query: query)
  }
  
  private func sendConfirmationEmail(_ req: Request, email: String, token: EmailConfirmationToken) async throws {
    
    let tokenId = try token.requireID().uuidString
    
    let query = Email.emailConfirmationRequest(
      tokenId: tokenId,
      email: email,
      logger: req.logger
    )
    
    try await req.sendEmail(query: query)
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
    
    static var defaultContentType: HTTPMediaType {
      .json
    }
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
  
  var apiKey: String? {
    application.environment.mailerSendApiKey
  }
  
  var sendEmail: URI {
    "https://api.mailersend.com/v1/email"
  }
  
  var autentiacted: HTTPHeaders {
    guard let apiKey else {
      logger.error("no MailerSend API Key")
      return [:]
    }
    return ["Authorization" : "Bearer \(apiKey)"]
  }
  
  func sendEmail(
    query: MailerSendEmail.Request
  ) async throws  {
    
    guard  !application.environment.emailsDisabled else {
      logger.notice("sending real emails disabled, email that would have been sent: \(query)")
      return
    }
    
    guard !autentiacted.isEmpty else {
      throw Abort(.internalServerError)
    }
       
        
    let response = try await client.post(
      sendEmail,
      headers: autentiacted,
      content: query
    )
        
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
      
    logger.notice("sent email with subject \"\(query.subject)\" from \(query.from.email) to \(query.to.first!.email)")
  }
}
