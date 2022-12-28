//
//  RecordAPIController.swift
//  
//
//  Created by Tomek Kuzma on 27/12/2022.
//


import Vapor
import FluentKit
import AppApi

extension Record.Detail : Content {}
extension Record.Update : Content {}


struct RecordAPIController {
  
  var dateProvider: DateProvider
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
  }
  
  func list(req:Request) async throws -> [Record.Detail] {
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.unauthorized)
    }
    
    guard
      let userModel = try await UserAccountModel
      .find(user.id, on: req.db)
    else {
      throw Abort(.notFound)
    }
    
    let records =  try await userModel
      .$records
      .query(on: req.db)
      .filter(\.$deleted == nil)
      .all()
      
    
    return records.map {
      $0.asDetail
    }
  }
  
  func updateRecord(req: Request) async throws -> Record.Detail {
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.unauthorized)
    }
    
    let recordUpdate = try req.content.decode(Record.Update.self)
    
    let existingRecord = try await RecordModel.find(recordUpdate.id, on: req.db)
    if let existingRecord {
      existingRecord.read(
        from: recordUpdate,
        dateProvider: dateProvider
      )
      try await existingRecord.save(on: req.db)
      return existingRecord.asDetail
    }
    
    let record = try RecordModel(
      from: recordUpdate,
      userId: user.id,
      dateProvider: dateProvider
    )
    
    try await record.create(on: req.db)
    
    return record.asDetail
  }
}

enum RecordModelError: Int, Error  {
  case missingAmount = 100
  case missingCurrency = 101
  case missingTitle = 102
}

extension RecordModel {
  
  convenience init(
    from update: Record.Update,
    userId: UUID,
    dateProvider: DateProvider
  ) throws {
    guard
      let amount = update.amount
    else {
      throw RecordModelError.missingAmount
    }
    
    guard
      let currency = update.currency
    else {
      throw RecordModelError.missingCurrency
    }
    
    guard let title = update.title else {
      throw RecordModelError.missingTitle
    }
    
    self.init(
      id: update.id,
      amount: amount,
      type: .expense,
      currency: currency,
      title: title,
      created: dateProvider.now,
      updated: dateProvider.now,
      userID: userId
    )
  }
  
  func read(
    from update: Record.Update,
    dateProvider: DateProvider
  ) {
    if let newTitle = update.title {
      self.title = newTitle
    }
    
    if let newAmount = update.amount {
      self.amount = newAmount
    }
    self.updated = update.updated
    if let newCurrency = update.currency {
      self.currency = newCurrency
    }
    if let newNotes = update.notes {
      self.notes = newNotes
    }
    self.deleted = update.deleted
  }
  
  var asDetail: Record.Detail {
    .init(
      id: id!,
      title: title,
      amount: amount,
      currency: currency,
      created: created,
      updated: updated,
      deleted: deleted
    )
  }
}
