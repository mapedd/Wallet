//
//  CurrencyRouter.swift
//  
//
//  Created by Tomek Kuzma on 07/01/2023.
//


import Vapor

struct CurrencyRouter: RouteCollection {
  
  var dateProvider: DateProvider
  let apiController: CurrencyAPIController
  
  init(
    dateProvider: DateProvider
  ) {
    self.dateProvider = dateProvider
    self.apiController = .init(dateProvider: dateProvider)
  }
  
  func boot(routes: RoutesBuilder) throws {
    
    let tokenAuthenticator = UserTokenAuthenticator(
      dateProvider: dateProvider
    )
    
    routes
      .grouped("api")
      .grouped(tokenAuthenticator)
      .grouped("currency")
      .get("list", use: apiController.list)
    
  }
}


