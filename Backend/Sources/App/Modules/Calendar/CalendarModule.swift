//
//  CalendarModule.swift
//  
//
//  Created by Tomek Kuzma on 06/04/2023.
//

import Foundation
import Vapor

struct CalendarModule: ModuleInterface {
  
  var router: CalendarRouter
  
  init(
    router: CalendarRouter
  ) {
    self.router = router
  }
  
  func boot(_ app: Application) throws {
    
    try self.router.boot(routes: app.routes)
  }
}

