//
//  UserAPITests.swift
//  
//
//  Created by Tomek Kuzma on 21/12/2022.
//

@testable import App
import XCTVapor
import FluentKit
import XCTest

final class UserAPITests: AppTestCase {
  
  func testRegisterSignInSignOutCreatesAndThenRemovesTokenCreatesUser() async throws {
    let app = try createTestApp()
    primeForReceivingClientRequests(app)
    
    defer { app.shutdown() }
    
    // check db has no user
    let users = try await UserAccountModel.query(on: app.db).filter(\.$email == "tom@bob.com").all()
    XCTAssertTrue(users.isEmpty)
    
    let userLogin = UserLogin(email: "tom@bob.com", password: "abc")
    let _ = try register(userLogin, app)
    
    
    let email = try XCTUnwrap(customClient.requestsReceived.first)
    XCTAssertEqual(email.url.host, "api.mailersend.com")
    XCTAssertEqual(email.url.path, "/v1/email")
    
    // check db has the user
    let usersAfterRegister = try await UserAccountModel.query(on: app.db).filter(\.$email == "tom@bob.com").all()
    XCTAssertEqual(usersAfterRegister.count, 1)
    
    let token = try authenticate(userLogin, app)
    let tokensSignedIn = try await UserTokenModel.query(on: app.db).all()
    XCTAssertEqual(tokensSignedIn.count, 1)
    
    let result = try signOut(token.token.value, app)
    XCTAssertTrue(result.success)
    
    let tokensSignedOut = try await UserTokenModel.query(on: app.db).all()
    XCTAssertTrue(tokensSignedOut.isEmpty)
  }
  
  func testRegisterSignInRefreshSignOut() async throws {
    var date = Date()
    let dateProvider = DateProvider(
      currentDate: { return date }
    )
    
    let app = try createTestApp(dateProvider: dateProvider)
    primeForReceivingClientRequests(app)
    defer { app.shutdown() }
    
    // check db has no user
    let users = try await UserAccountModel.query(on: app.db).filter(\.$email == "tom@bob.com").all()
    XCTAssertTrue(users.isEmpty)
    
    let userLogin = UserLogin(email: "tom@bob.com", password: "abc")
    let _ = try register(userLogin, app)
    
    // check db has the user
    let usersAfterRegister = try await UserAccountModel.query(on: app.db).filter(\.$email == "tom@bob.com").all()
    XCTAssertEqual(usersAfterRegister.count, 1)
    
    let token = try authenticate(userLogin, app)
    // here we should get a token valid for 60 seconds
    // before next call we will decrease time in `date` to simulate token invalid
    // which should result in refreshing of the token
    let tokensSignedIn = try await UserTokenModel.query(on: app.db).all()
    XCTAssertEqual(tokensSignedIn.count, 1)
    
    date = date.addingTimeInterval(-60 * 60) // simute token 1hr old
    
    let result = try signOut(token.token.value, app)
    
    XCTAssertTrue(result.success)
  }
}
