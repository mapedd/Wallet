//
//  RecordModule.swift
//
//
//  Created by Tomek Kuzma on 23/12/2022.
//

import Vapor

struct RecordModule: ModuleInterface {
  
  var router: RecordRouter
  
  init(
    router: RecordRouter
  ) {
    self.router = router
  }
  
  func boot(_ app: Application) throws {
    app.migrations.add(RecordModelMigrations.v1())
    try self.router.boot(routes: app.routes)
  }
}

