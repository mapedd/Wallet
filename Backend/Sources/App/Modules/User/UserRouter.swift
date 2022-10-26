//
//  UserRouter.swift
//  
//
//  Created by Tomek Kuzma on 26/10/2022.
//

import Vapor

struct UserRouter: RouteCollection {
    
    let frontendController = UserFrontendController()
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("sign-in", use: frontendController.signInView)
        routes.post("sign-in", use: frontendController.signInAction)
    }
    
}
