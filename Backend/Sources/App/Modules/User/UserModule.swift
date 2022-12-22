//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor
import SwiftHtml

struct UserModule: ModuleInterface {
  
  var router: UserRouter
  
  init(
    router: UserRouter
  ) {
    self.router = router
  }
  
  func boot(_ app: Application) throws {
    app.migrations.add(UserMigrations.v1())
    app.migrations.add(UserMigrations.seed())
    
    app.middleware.use(UserSessionAuthenticator())
    app.middleware.use(UserTokenAuthenticator(dateProvider: router.dateProvider))
    
    try self.router.boot(routes: app.routes)
  }
}

