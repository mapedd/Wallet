//
//  RecordAPIController.swift
//  
//
//  Created by Tomek Kuzma on 27/12/2022.
//


import Vapor
import FluentKit

enum Record {
  struct Create: Codable,Hashable, Content {
    var id: UUID
    var title: String
    var amount: Decimal
  }
  
  struct List: Codable,Hashable, Content {
    var id: UUID
    var title: String
    var amount: Decimal
    var created: Date
    var updated: Date
    var deleted: Date?
  }
}

struct RecordAPIController {
  
  var dateProvider: DateProvider
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
  }
  
  func list(req:Request) async throws -> [Record.List] {
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.unauthorized)
    }
    
    guard
      let userModel = try await UserAccountModel
      .find(user.id, on: req.db)
    else {
      throw Abort(.notFound)
    }
    
    let records =  try await userModel.$records.get(on: req.db)
    
    return records.map {
      Record.List(
        id: $0.id!,
        title: $0.title,
        amount: $0.amount,
        created: $0.created,
        updated: $0.updated,
        deleted: $0.deleted
      )
    }
  }
  
  func createRecord(req: Request) async throws -> Record.Create {
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.unauthorized)
    }
    let recordCreate = try req.content.decode(Record.Create.self)
    
    let record = RecordModel(
      id: recordCreate.id,
      amount: recordCreate.amount,
      type: .expense,
      currency: .pln,
      title: recordCreate.title,
      created: dateProvider.now,
      updated: dateProvider.now,
      userID: user.id
    )
    
    try await record.create(on: req.db)
    
    return recordCreate
  }
}
