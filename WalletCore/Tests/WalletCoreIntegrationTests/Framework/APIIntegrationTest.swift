//
//  APIIntegrationTest.swift
//  
//
//  Created by Tomek Kuzma on 11/02/2023.
//

import XCTest
import App
import Vapor
import XCTVapor

class APIIntegrationTest: XCTestCase {
  
  //  func serverDirectory(path: String = #file) -> String {
  //    let url = URL(fileURLWithPath: path)
  //    let testsDir = url
  //      .deletingLastPathComponent()
  //      .deletingLastPathComponent()
  //      .deletingLastPathComponent()
  //      .deletingLastPathComponent()
  //
  //    return testsDir
  //      .appendingPathComponent("Backend")
  //      .aml_toFilePath
  //  }
  
  
  //  override func setUp() async throws {
  //    try await super.setUp()
  //
  //    do {
  //      try shellOut(
  ////        to: "vapor run --env testing",
  //        to: "eval \"$(/opt/homebrew/bin/brew shellenv)\"; vapor run --env testing&",
  //        at: serverDirectory()
  //      )
  //    } catch {
  //      let error = error as! ShellOutError
  //      print(error.message) // Prints STDERR
  //      print(error.output) // Prints STDOUT
  //    }
  //    try await Task.sleep(nanoseconds: 10 * NSEC_PER_SEC)
  //  }
  //
  //  override func tearDown() async throws {
  //    try await super.tearDown()
  //
  //    do {
  //
  //      try shellOut(
  //        to: "lsof -i :8080 -sTCP:LISTEN |awk 'NR > 1 {print $2}'|xargs kill -15",
  //        at: serverDirectory()
  //      )
  //    } catch {
  //      let error = error as! ShellOutError
  //      print(error.message) // Prints STDERR
  //      print(error.output) // Prints STDOUT
  //    }
  //  }
  //
  
  
  
  
  
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
