//
//  RecordAPITests.swift
//  
//
//  Created by Tomek Kuzma on 27/12/2022.
//

@testable import App
import XCTVapor
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
    
    let record = Record.Create(
      id: uuid,
      title: "record-title",
      amount: .init(0)
    )
    
    let output = try await create(record: record, app: app, token: token)
    
    XCTAssertEqual(record, output)
    
    let recordsAfterCreate = try await RecordModel.query(on: app.db).all()
    
    XCTAssertEqual(recordsAfterCreate.count, 1)
    
    app.shutdown()
  }
  
}
