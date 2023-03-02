//
//  UserRouter.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor

struct UserRouter: RouteCollection {
  
  enum Route: String {
    case signIn = "sign-in"
    case forgotPassword = "forgot-password"
    case deleteAccount = "delete-account"
    case signOut = "sign-out"
    case register = "register"
    case confirmPassword = "confirmPassword"
    
    var href : String {
      "/\(rawValue)"
    }
    
    var pathComponent: PathComponent {
      return .constant(rawValue)
    }
  }
  
  var dateProvider: DateProvider
  var frontendController: UserFrontendController
  var apiController: UserApiController
  
  init(
    dateProvider: DateProvider
  ) {
    self.dateProvider = dateProvider
    self.apiController = .init(dateProvider: dateProvider)
    self.frontendController = .init(userApiController: self.apiController)
  }
  
  func bootFrontend(_ routes: RoutesBuilder) throws {
    routes
      .get(Route.signIn.pathComponent, use: frontendController.signInView)
    
    routes
      .get(Route.forgotPassword.pathComponent, use: frontendController.forgotPassword)
    
    routes
      .get(Route.register.pathComponent, use: frontendController.register)
    
    routes
      .grouped(UserCredentialsAuthenticator())
      .post(Route.signIn.pathComponent, use: frontendController.signInAction)
    
    routes
      .get(Route.forgotPassword.pathComponent, use: frontendController.remindPasswordAction)
    
    routes
      .post(Route.register.pathComponent, use: frontendController.registerAction)
    
    routes
      .get(Route.signOut.pathComponent, use: frontendController.signOut)
    
    routes
      .get(Route.confirmPassword.pathComponent, use: frontendController.confirmPassword)
    
  }
  
  func bootAPI(_ routes: RoutesBuilder) throws {
    // for login in
    let loginAuthenticator = UserCredentialsAuthenticator()
    // post login
    let tokenAuthenticator = UserTokenAuthenticator(dateProvider: dateProvider)
    
    routes
      .grouped("api")
      .grouped(loginAuthenticator)
      .post("sign-in", use: apiController.signInApi)
    
    
    routes
      .grouped("api")
      .grouped(tokenAuthenticator)
      .get("sign-out", use: apiController.signOut)
    
    routes
      .grouped("api")
      .grouped(tokenAuthenticator)
      .get("user", use: apiController.details)
    
    routes
      .grouped("api")// internally validation of token since we need pair
      .post("refresh-token", use: apiController.refresh)
    
    routes
      .grouped("api")
      .post("register", use: apiController.register)
    
    routes
      .grouped("api")
      .post(Route.forgotPassword.pathComponent, use: apiController.remindPassword)
    
    routes
      .grouped("api")
      .get("users", use: apiController.listAll)
    
    
//    routes
//      .grouped("api")
//      .get("*", use: apiController.any)
  }
  
  func boot(routes: RoutesBuilder) throws {
    try bootFrontend(routes)
    try bootAPI(routes)
  }
}
