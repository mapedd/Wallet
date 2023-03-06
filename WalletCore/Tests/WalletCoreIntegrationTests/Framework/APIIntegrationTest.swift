//
//  APIIntegrationTest.swift
//  
//
//  Created by Tomek Kuzma on 11/02/2023.
//

import XCTest
import App
import Vapor
import AppTestingHelpers
import XCTVapor

class APIIntegrationTest: XCTestCase {
  
  
  func createTestApp(
    dateProvider: App.DateProvider = .init(currentDate: { Date() })
  ) throws -> Application {
    let app = Application(.testing)
    
    do {
      try configure(app, dateProvider: dateProvider)
      try app.autoMigrate().wait()
    }
    catch {}
    return app
  }
  
}
