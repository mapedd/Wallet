//
//  RecordAPITests.swift
//  
//
//  Created by Tomek Kuzma on 27/12/2022.
//

@testable import App
import XCTVapor
import CustomDump
import FluentKit
import XCTest

extension UUID {
  static let beef = UUID(uuidString: "deadbeef-dead-dead-dead-deaddeafbeef")!
}

extension UUID {
  enum Digit: Int {
    case zero
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
  }
  static func digit(_ digit: Digit) -> UUID {
    .init(uuidString: "00000000-0000-0000-0000-00000000000\(digit.rawValue)")!
  }
}

extension Record.Update {
  static func sample(_ id: Int, date: Date = Date()) -> Record.Update {
    .init(
      id: .digit(.init(rawValue: id)!),
      title: "record-title-\(id)",
      amount: .init(id),
      type: .expense,
      currencyCode: "USD",
      notes: "notes",
      categoryIds: [],
      updated: Date(),
      deleted: nil
    )
  }
  
  
  var asDetail: Record.Detail {
    .init(
      id: id,
      title: title,
      amount: amount,
      type: type,
      currencyCode: currencyCode,
      notes: notes,
      categories: [],
      created: updated,
      updated: updated,
      deleted: nil
    )
  }
}

final class RecordAPITests: AppTestCase {
  
  func testCreatingRecords() async throws { 
    let app = try createTestApp()
    defer {
      app.shutdown()
    }
    let token = try await registerAndSignInUser(app: app)
    
    let records = try await RecordModel.query(on: app.db).all()
    // check db has no user
    XCTAssertTrue(records.isEmpty)
    
    let record = Record.Update.sample(1)
    let detailExpected = record.asDetail
    
    let output = try await update(record: record, app: app, token: token)
    
    XCTAssertEqual(detailExpected.id, output.id)
    XCTAssertEqual(detailExpected.title, output.title)
    XCTAssertEqual(detailExpected.amount, output.amount)
    XCTAssertEqual(detailExpected.type, output.type)
    
    let recordsAfterCreate = try await RecordModel.query(on: app.db).all()
    
    let formatter = ISO8601DateFormatter()
    
    let dateOut = formatter.string(from: output.updated)
    let dateIn = formatter.string(from: detailExpected.updated)
    XCTAssertEqual(dateOut, dateIn)
    XCTAssertEqual(recordsAfterCreate.count, 1)
    
    let recordInDB = try XCTUnwrap(recordsAfterCreate.first)
    XCTAssertEqual(recordInDB.id, detailExpected.id)
    
  }
  
  func testUpdatingRecords_title() async throws {
    let app = try createTestApp()
    defer {
      app.shutdown()
    }
    let token = try await registerAndSignInUser(app: app)
    
    let records = try await RecordModel.query(on: app.db).all()
    // check db has no user
    XCTAssertTrue(records.isEmpty)
    
    var record = Record.Update.sample(1)
    let detailExpected = record.asDetail
    
    let _ = try await update(record: record, app: app, token: token)
    
    record.title = "update_title"
    
    let updatedRecord = try await update(record: record, app: app, token: token)
    
    XCTAssertEqual(detailExpected.id, updatedRecord.id)
    XCTAssertEqual("update_title", updatedRecord.title)
    
    let recordsAfterCreate = try await RecordModel.query(on: app.db).all()
    
    let formatter = ISO8601DateFormatter()
    
    let dateOut = formatter.string(from: updatedRecord.updated)
    let dateIn = formatter.string(from: detailExpected.updated)
    XCTAssertEqual(dateOut, dateIn)
    // should not create new, just update existing 
    XCTAssertEqual(recordsAfterCreate.count, 1)
    
    let recordInDB = try XCTUnwrap(recordsAfterCreate.first)
    XCTAssertEqual(recordInDB.id, detailExpected.id)
    
  }
  
  func testUpdatingRecords_categories() async throws {
    let app = try createTestApp()
    defer {
      app.shutdown()
    }
    
    let token = try await registerAndSignInUser(app: app)
    let categoryModel0 = RecordCategoryModel(id: nil, name: "category_0", color: 1)
    let categoryModel1 = RecordCategoryModel(id: nil, name: "category_1", color: 2)
    
    
    try await [
      categoryModel0,
      categoryModel1
    ].create(on: app.db)
    
    var record = Record.Update.sample(1) // create without categories
    record.categoryIds = [
      categoryModel0.id!,
      categoryModel1.id!,
    ]
    
    
    let getCategoryNames : (Record.Detail) -> [String] = { record in
      record.categories.map(\.name).sorted()
    }
  
    let freshRecord = try await update(record: record, app: app, token: token)
    XCTAssertEqual(getCategoryNames(freshRecord), ["category_0", "category_1"])
    
    // update with 2 categories
    record.categoryIds = [
      categoryModel0.id!,
      categoryModel1.id!,
    ]
    
    
    let updatedRecord = try await update(record: record, app: app, token: token)
    XCTAssertEqual(getCategoryNames(updatedRecord), ["category_0", "category_1"])
    
    guard
      let recordModel = try await RecordModel
      .query(on: app.db)
      .filter(\.$id == record.id)
      .all()
      .first
    else {
      XCTFail("Cannot find record in db")
      return
    }
    
    guard let categories = try? await recordModel.$categories.get(on: app.db) else {
      XCTFail("Cannot find record in db")
      return
    }
    
    XCTAssertEqual(categories.map(\.name).sorted(), ["category_0", "category_1"])
    
    // update again but remove one of the categories
    record.categoryIds = [
      categoryModel0.id!
    ]
    
    let updatedRecordAfterRemove = try await update(record: record, app: app, token: token)
    XCTAssertEqual(getCategoryNames(updatedRecordAfterRemove), ["category_0"])
    
    // update again but change from one to another
    record.categoryIds = [
      categoryModel1.id!
    ]
    
    let updatedRecordAfterChangeCategory = try await update(record: record, app: app, token: token)
    XCTAssertEqual(getCategoryNames(updatedRecordAfterChangeCategory), ["category_1"])
    
    // update again but remove completely
    record.categoryIds = [
    ]
    
    let updatedRecordAfterRemoveAll = try await update(record: record, app: app, token: token)
    XCTAssertTrue(updatedRecordAfterRemoveAll.categories.isEmpty)
    
  }
}
