//
//  RecordModule.swift
//  
//
//  Created by Tomek Kuzma on 23/12/2022.
//

import Vapor
import SwiftHtml

struct RecordModule: ModuleInterface {
  
//  var router: UserRouter
//
//  init(
//    router: UserRouter
//  ) {
//    self.router = router
//  }
  
  func boot(_ app: Application) throws {
    app.migrations.add(RecordModelMigrations.v1())
  }
//
//    app.middleware.use(UserSessionAuthenticator())
//    app.middleware.use(UserTokenAuthenticator(dateProvider: router.dateProvider))
//
//    try self.router.boot(routes: app.routes)
//  }
}

