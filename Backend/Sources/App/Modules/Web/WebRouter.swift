//
//  WebRouter.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Vapor

struct WebRouter: RouteCollection {
    
    let frontendController = WebFrontendController()
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: frontendController.homeView)
    }
}
