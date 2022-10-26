//
//  BlogModule.swift
//  
//
//  Created by Tomek Kuzma on 25/10/2022.
//

import Foundation

import Vapor
struct BlogModule: ModuleInterface {
    let router = BlogRouter()
    func boot(_ app: Application) throws {
        app.migrations.add(BlogMigrations.v1())
        app.migrations.add(BlogMigrations.seed()
        )
        try router.boot(routes: app.routes)
    }
}
