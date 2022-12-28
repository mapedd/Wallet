//
//  RecordRouter.swift
//  
//
//  Created by Tomek Kuzma on 27/12/2022.
//


import Vapor

struct RecordRouter: RouteCollection {
  
  var dateProvider: DateProvider
  let apiController: RecordAPIController
  
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
      .grouped("record")
      .post("update", use: apiController.updateRecord)
    
    
    routes
      .grouped("api")
      .grouped(tokenAuthenticator)
      .grouped("record")
      .get("list", use: apiController.list)
    
  }
}

