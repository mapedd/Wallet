//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor

struct UserFrontendController {
  
  var userApiController: UserApiController
  
  private func renderSignInView(_ req: Request, _ form: UserLoginForm) -> Response {
    let template = UserLoginTemplate(
      context: .init(
        mode: form.mode,
        form: form.render(req: req)
      )
    )
    return req.templates.renderHtml(template)
  }
  
  func signInView(_ req: Request) async throws -> Response {
    renderSignInView(req, .init(mode: .signin))
  }
  
  func register(_ req: Request) async throws -> Response {
    renderSignInView(req, .init(mode: .register))
  }
  
  func forgotPassword(_ req: Request) async throws -> Response {
    renderSignInView(req, .init(mode: .remindPassword))
  }
  
  func signInAction(_ req: Request) async throws -> Response {
    /// the user is authenticated, we can store the user data inside the session too
    if let user = req.auth.get(AuthenticatedUser.self) {
      req.session.authenticate(user)
      return req.redirect(to: "/")
    }
    let form = UserLoginForm()
    try await form.process(req: req)
    if try await form.validate(req: req) {
      form.error = "Invalid email or password."
    }
    return renderSignInView(req, form)
  }
  
  func registerAction(_ req: Request) async throws -> Response {
    let user = try await userApiController.register(req: req)
  
    let template = UserInfoTemplate(
      context: .init(
        title: "Welcome \(user.fullName)",
        message: "Please check your mailbox and confirm your email"
      )
    )
    return req.templates.renderHtml(template)
  }
  
  func remindPasswordAction(_ req: Request) async throws -> Response {
    return req.redirect(to: "/")
  }
  
  func signOut(req: Request) throws -> Response {
    req.auth.logout(AuthenticatedUser.self)
    req.session.unauthenticate(AuthenticatedUser.self)
    return req.redirect(to: "/")
  }
  
  func confirmPassword(req: Request) async throws  -> Response {
    req.logger.notice("received email confirmation request")
    let confirmEmail = try req.query.decode(ConfirmationTokenPayload
      .self)
    req.logger.notice("will try to confirmation request with id \(confirmEmail.token)")
    guard
      let model = try await EmailConfirmationToken
      .find(confirmEmail.token, on: req.db)
    else {
      throw Abort(.conflict)
    }
    
    let user = try await model.$user.get(on: req.db)
    
    req.logger.notice("found confirmation token for user with id \(user.id!)!")
    
    let linkDead = UserInfoTemplate(context: .init(title: "Link invalid", message: "Link dead bro"))
    guard
      let tokenCreation = model.created,
      !userApiController.dateProvider.emailConfirmationValid(date: tokenCreation)
    else {
      req.logger.notice("confirmation token expired")
      return req.templates.renderHtml(linkDead)
    }
    
    req.logger.notice("confirmation succeeded for user \(user.id!)")
    user.emailConfirmed = userApiController.dateProvider.now
    
    try await user.save(on: req.db)
    
    return req.redirect(to: UserRouter.Route.signIn.href)
  }
  
  func confirmAccountDeletion(req: Request)  async throws -> Response {
    req.logger.notice("received delete account confirmation request")
    let confirmDelete = try req.query.decode(ConfirmationTokenPayload.self)
    req.logger.notice("will try to confirmation request with id \(confirmDelete.token)")
    guard
      let model = try await DeleteAccountToken
      .find(confirmDelete.token, on: req.db)
    else {
      throw Abort(.conflict)
    }
    
    let user = try await model.$user.get(on: req.db)
    
    req.logger.notice("found account deletion token for user with id \(user.id!)!")
    
    let linkDead = UserInfoTemplate(context: .init(title: "Link invalid", message: "Link dead bro"))
    guard
      let tokenCreation = model.created,
      !userApiController.dateProvider.deleteAccountConfirmationValid(date: tokenCreation)
    else {
      req.logger.notice("confirmation token expired")
      return req.templates.renderHtml(linkDead)
    }
    
    req.logger.notice("delete account succeeded for user \(user.id!)")
    user.deleted = userApiController.dateProvider.now
    
    try await user.save(on: req.db)
    
    return req.redirect(to: "/")
  }
}

struct ConfirmationTokenPayload: Codable {
  let token: UUID
}
