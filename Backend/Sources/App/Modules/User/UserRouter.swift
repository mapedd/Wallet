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
    
    func boot(routes: RoutesBuilder) throws {
        routes
            .get("sign-in", use: frontendController.signInView)
        
        routes
            .grouped(UserCredentialsAuthenticator())
            .post("sign-in", use: frontendController.signInAction)

        routes.get("sign-out", use: frontendController.signOut)
        
        routes
            .grouped("api")
            .grouped(UserCredentialsAuthenticator())
            .post("sign-in", use: apiController.signInApi)
        
        routes
            .grouped("api")
            .post("register", use: apiController.register)
      
      routes
          .grouped("api")
          .grouped(UserCredentialsAuthenticator())
          .get("sign-out", use: apiController.signOut)
      
      routes
        .grouped("api")
        .post("refresh-token", use: apiController.refresh)
        
        routes
            .grouped("api")
            .get("users", use: apiController.listAll)
    }
}
