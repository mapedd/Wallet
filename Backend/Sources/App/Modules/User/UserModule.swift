//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 26/10/2022.
//



import Vapor

struct UserModule: ModuleInterface {
    
    let router = UserRouter()
    
    func boot(_ app: Application) throws {
        app.migrations.add(UserMigrations.v1())
        app.migrations.add(UserMigrations.seed())
        
        try router.boot(routes: app.routes)
    }
}
