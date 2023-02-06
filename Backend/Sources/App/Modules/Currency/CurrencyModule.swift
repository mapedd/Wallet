//
//  Currency.swift
//  
//
//  Created by Tomek Kuzma on 07/01/2023.
//


import Vapor

struct CurrencyModule: ModuleInterface {
  
  var router: CurrencyRouter
  
  init(
    router: CurrencyRouter
  ) {
    self.router = router
  }
  
  func boot(_ app: Application) throws {
    try self.router.boot(routes: app.routes)
  }
}

