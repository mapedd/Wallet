//
//  AuthManagerTests.swift
//  Tests iOS
//
//  Created by Tomek Kuzma on 21/12/2022.
//

import XCTest
@testable import WalletCore
import AppApi

final class AuthManagerTests: XCTestCase {
  class Harness {
    
    var savedToken: Token?
    
    static func refreshedToken(date: Date, counter: Int) -> Token {
      Token(
        value: "refreshedToken\(counter)",
        validDate: date,
        refreshToken: "refreshedRefresh\(counter)"
      )
    }
    
    var storedRefreshTokens: [String] = []
    
    var currentDate: () -> Date
    
    init(currentDate: @escaping () -> Date = { Date() }) {
      self.currentDate = currentDate
    }
    
    lazy var authNetwork: AuthNetwork = {
      .init(
        refreshToken: {
          self.storedRefreshTokens.append($0)
          return Self.refreshedToken(
            date: self.currentDate(),
            counter: self.storedRefreshTokens.count
          )
        }
      )
    }()
    
    lazy var sut: AuthManager = {
      AuthManager(
        keychain: .init(
          saveToken: { token in
            self.savedToken = token
          },
          readToken: {
            self.savedToken
          }
        ),
        authNetwork: authNetwork,
        dateProvider: .init(
          currentDate: currentDate
        )
      )
    }()
  }
  func testCurrentTokenNotStored() async throws {
    let harness = Harness()
    do {
      let _ =  try await harness.sut.validToken()
      XCTFail("should throw")
    } catch {
      XCTAssertEqual(error as! AuthError, AuthError.noTokenStored)
    }
  }
  
  func testCurrentTokenExpiredTriggersRefresh() async throws {
    let validDate = Date()
    let harness = Harness(currentDate: {
      validDate.addingTimeInterval(1) // should be after valid date
    })
    
    harness.savedToken = .init(
      value: "token",
      validDate: validDate,
      refreshToken: "refresh"
    )
    
    let _ =  try await harness.sut.validToken()
    
    XCTAssertEqual(harness.storedRefreshTokens, ["refresh"])
  }
  
  func testTokenReturnedIfNotExpiredAndDoesNotTriggerNewRefresh() async throws {
    let validDate = Date()
    let harness = Harness(currentDate: {
      validDate.addingTimeInterval(-1) // should be after valid date
    })
    
    harness.savedToken = .init(
      value: "token1",
      validDate: validDate,
      refreshToken: "refresh"
    )
    
    let token =  try await harness.sut.validToken()
    XCTAssertEqual(token.value, "token1")
    XCTAssertEqual(harness.storedRefreshTokens.count, 0)
  }
  
  func testAfterRefreshingNewTokenIsReturned() async throws {
    let validDate = Date()
    let harness = Harness(currentDate: {
      validDate.addingTimeInterval(1) // should be after valid date
    })
    
    harness.savedToken = .init(
      value: "token",
      validDate: validDate,
      refreshToken: "refresh"
    )
    
    let token =  try await harness.sut.validToken()
    
    XCTAssertEqual(token.value, "refreshedToken1")
  }
  
  func testTriggeringRefreshingMultipleTimesDoesNotCallAPIMultipleTimes() async throws {
    let validDate = Date()
    let harness = Harness(currentDate: {
      validDate.addingTimeInterval(1) // should be after valid date
    })
    
    harness.savedToken = .init(
      value: "token",
      validDate: validDate,
      refreshToken: "refresh"
    )
    
    harness.authNetwork = .init(
      refreshToken: { refreshToken in 
        harness.storedRefreshTokens.append(refreshToken)
        try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 30)
        return Harness.refreshedToken(
          date: Date(),
          counter: harness.storedRefreshTokens.count
        )
      }
    )
    
    let task = Task {
      return try await harness.sut.validToken()
    }
    try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 2)
    let task0 = Task {
      return try await harness.sut.validToken()
    }
    try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 2)
    let task1 = Task {
      return try await harness.sut.validToken()
    }
    try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 2)
    let task2 = Task {
      return try await harness.sut.validToken()
    }
    
    let token = try await task.value
    let token0 = try await task0.value
    let token1 = try await task1.value
    let token2 = try await task2.value
    
    XCTAssertEqual(harness.storedRefreshTokens, ["refresh"])
    XCTAssertEqual(token.value, "refreshedToken1")
    XCTAssertEqual(token0.value, "refreshedToken1")
    XCTAssertEqual(token1.value, "refreshedToken1")
    XCTAssertEqual(token2.value, "refreshedToken1")
  }
}
