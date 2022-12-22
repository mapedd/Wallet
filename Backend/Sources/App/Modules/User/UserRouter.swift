//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor

struct UserRouter: RouteCollection {
  
  let frontendController = UserFrontendController()
  
  let apiController = UserApiController()
  
  func bootFrontend(_ routes: RoutesBuilder) throws {
    routes
      .get("sign-in", use: frontendController.signInView)
    
    routes
      .grouped(UserCredentialsAuthenticator())
      .post("sign-in", use: frontendController.signInAction)
    
    routes.get("sign-out", use: frontendController.signOut)
    
  }
  
  func bootAPI(_ routes: RoutesBuilder) throws {
    // for login in
    let loginAuthenticator = UserCredentialsAuthenticator()
    // post login
    let tokenAuthenticator = UserTokenAuthenticator()
    
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
      .get("refresh-token", use: apiController.refresh)
    
    
    routes
      .grouped("api")
      .post("register", use: apiController.register)
    
    routes
      .grouped("api")
      .get("users", use: apiController.listAll)
  }
  
  func boot(routes: RoutesBuilder) throws {
    try bootFrontend(routes)
    try bootAPI(routes)
  }
}
