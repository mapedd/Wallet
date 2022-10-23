//
//  BlogRouter.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Vapor

struct BlogRouter: RouteCollection {
    
    let controller = BlogFrontendController()
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("blog", use: controller.blogView)
        routes.get(.anything, use: controller.postView)
    }
}
