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
    let tokensSignedIn = try await UserTokenModel.query(on: app.db).all()
    XCTAssertEqual(tokensSignedIn.count, 1)
    
    let result = try signOut(token.token.value, app)
    XCTAssertTrue(result.success)
    
    let tokensSignedOut = try await UserTokenModel.query(on: app.db).all()
    XCTAssertTrue(tokensSignedOut.isEmpty)
  }
  
  func testRegisterSignInRefreshSignOut() async throws {
    
  }
}
