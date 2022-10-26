//
//  UserFrontendController.swift
//  
//
//  Created by Tomek Kuzma on 26/10/2022.
//

import Foundation

import Vapor
struct UserFrontendController {
    
    func signInView(_ req: Request) async throws -> Response {
        let template = UserLoginTemplate(
            .init(
                icon: "⬇️",
                title: "Sign in",
                message: "Please log in with your existing  account "
            )
        )
        
        return req.templates.renderHtml(template)
    }
    
    func signInAction(_ req: Request) async throws -> Response {
        // @TODO: handle sign in action
        return try await signInView(req)
    }
    
}

