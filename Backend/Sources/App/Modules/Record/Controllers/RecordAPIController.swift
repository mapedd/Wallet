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

extension RecordCategory.Detail: Content {}
extension RecordCategory.Create : Content {}


struct RecordAPIController {
  
  var dateProvider: DateProvider
  let encoder: JSONEncoder
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
    
    encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
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
      
    
    return try await records.asyncMap {
      try await $0.asDetail(on: req.db)
    }
  }
  func log(_ action: String, _ details: Record.Detail,_ req: Request)  {
    
    do {
      let json = try encoder.encode(details)
      req.logger.info("\(action) record \(String(data: json, encoding: .utf8) ?? "")")
    } catch {}
  }
  func updateRecord(req: Request) async throws -> Record.Detail {
    guard let user = req.auth.get(AuthenticatedUser.self) else {
      throw Abort(.unauthorized)
    }
    
    let recordUpdate = try req.content.decode(Record.Update.self)
    
    let existingRecord = try await RecordModel.find(recordUpdate.id, on: req.db)
    if let existingRecord {
      try await existingRecord.read(
        from: recordUpdate,
        dateProvider: dateProvider,
        db: req.db
      )
      try await existingRecord.save(on: req.db)
      let details = try await existingRecord.asDetail(on: req.db)
      log("updated", details, req)
      return details
    }
    
    let record = try RecordModel(
      from: recordUpdate,
      userId: user.id,
      dateProvider: dateProvider
    )
    
    try await record.read(
      from: recordUpdate,
      dateProvider: dateProvider,
      db: req.db
    )
    
    try await record.create(on: req.db)
    let createdIn = recordUpdate.updated
    let detail = try await record.asDetail(on: req.db)
    log("created", detail, req)
    let createdOut = detail.updated
    if createdIn != createdOut {
      req.logger.info("dates not equal \(createdOut) \(createdIn)")
    }
    return detail
  }
  
  
  func createCategory(req: Request) async throws -> RecordCategory.Detail {
    let categoryUpdate = try req.content.decode(RecordCategory.Create.self)
    let newCategory = RecordCategoryModel(
      name: categoryUpdate.name,
      color: categoryUpdate.color
    )
    
    try await newCategory.save(on: req.db)
    
    return newCategory.asDetail
  }
  func listCategories(req: Request) async throws -> [RecordCategory.Detail] {
    let categories = try await RecordCategoryModel.query(on: req.db).all()
    return categories.map { $0.asDetail }
  }
  
}

enum RecordModelError: Int, Error  {
  case missingAmount = 100
  case missingCurrency = 101
  case missingTitle = 102
  case missingType = 103
}

extension RecordModel {
  
  convenience init(
    from update: Record.Update,
    userId: UUID,
    dateProvider: DateProvider
  ) throws {
    
    self.init(
      id: update.id,
      amount: update.amount,
      type: update.type,
      currencyCode: update.currencyCode,
      title: update.title,
      created: dateProvider.now,
      updated: dateProvider.now,
      userID: userId
    )
  }
  
  func read(
    from update: Record.Update,
    dateProvider: DateProvider,
    db: Database
  ) async throws {
    
    self.title = update.title
    self.amount = update.amount
    self.updated = update.updated
    self.currencyCode = update.currencyCode
    self.notes = update.notes
    self.type = update.type
    self.deleted = update.deleted
    
    let categories = try await  RecordCategoryModel.query(on: db).filter(\.$id ~~ update.categoryIds).all()
    
    for category in categories {
      try await self.$categories.attach(category, method: .ifNotExists, on: db)
    }
  }
  
  func asDetail(on db: Database) async throws ->  Record.Detail {
    guard let categories = try? await self.$categories.get(on: db) else {
      throw Abort(.internalServerError)
    }
    return .init(
      id: id!,
      title: title,
      amount: amount,
      type: type,
      currencyCode: currencyCode,
      notes: notes,
      categories: categories.map { $0.asDetail },
      created: created,
      updated: updated,
      deleted: deleted
    )
  }
}


extension RecordCategoryModel {
  var asDetail: RecordCategory.Detail {
    .init(
      id: id!,
      name: name,
      color: color
    )
  }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
