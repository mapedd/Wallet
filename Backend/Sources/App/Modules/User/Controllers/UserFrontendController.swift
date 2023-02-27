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
    return req.redirect(to: "/")
  }
  
  func remindPasswordAction(_ req: Request) async throws -> Response {
    return req.redirect(to: "/")
  }
  
  func signOut(req: Request) throws -> Response {
    req.auth.logout(AuthenticatedUser.self)
    req.session.unauthenticate(AuthenticatedUser.self)
    return req.redirect(to: "/")
  }
}
