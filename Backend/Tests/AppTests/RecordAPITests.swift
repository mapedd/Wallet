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

final class RecordAPITests: AppTestCase {
  
  func testCreatingRecords() async throws {
    let app = try createTestApp()
    
    let token = try await registerAndSignInUser(app: app)
    
    let records = try await RecordModel.query(on: app.db).all()
    // check db has no user
    XCTAssertTrue(records.isEmpty)
    
    let uuid = UUID(uuidString: "deadbeef-dead-dead-dead-deaddeafbeef")!
    let date = Date()
    let record = Record.Update(
      id: uuid,
      title: "record-title",
      amount: .init(0),
      type: .expense,
      currencyCode: "USD",
      notes: "notes",
      categoryIds: [],
      updated: date,
      deleted: nil
    )
    
    let detailExpected = Record.Detail(
      id: uuid,
      title: "record-title",
      amount: .init(0),
      type: .expense,
      currencyCode: "USD",
      notes: "notes",
      categories: [],
      created: date,
      updated: date,
      deleted: nil
    )
    
    let output = try await create(record: record, app: app, token: token)
    
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
    
    app.shutdown()
  }
  
}
