//
//  LoginFeatureTests.swift
//  WalletiOSTests
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import XCTest
import ComposableArchitecture
import XCTestDynamicOverlay
import AppApi
import WalletCore


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

extension Date {
  static var test: Date {
    Date(timeIntervalSince1970: 714815923.122)
  }
}

extension User.Token.Detail {
  static var sample: User.Token.Detail {
    .init(
      id: .digit(.one),
      token: .init(
        value: "value",
        expiry: .test,
        refresh: "refresh"
      ),
      user: .init(
        id: .digit(.two),
        email: "email"
      )
    )
  }
}

@MainActor
final class LoginFeatureTests: XCTestCase {
  
  func testLoginCallsApiAndReturnTokenShowsProgress() async {
    
    let store = TestStore(
      initialState: .init(),
      reducer: Login(),
      prepareDependencies: { _ in }
    )
    store.dependencies.apiClient.signIn = { _ in
        .sample
    }
    await store.send(.logIn) {
      $0.loading = true
    }
    await store.receive(.loggedIn(.sample), timeout: .seconds(1)) {
      $0.loading = false
    }
  }
  
  func testLoginFailing() async {
    
    let store = TestStore(
      initialState: .init(),
      reducer: Login(),
      prepareDependencies: { _ in }
    )
    store.dependencies.apiClient.signIn = { _ in
      throw URLError(.cannotFindHost)
    }
    await store.send(.logIn) {
      $0.loading = true
    }
    await store.receive(.loginFailed(.apiError(URLError(.cannotFindHost))), timeout: .seconds(1)) {
      $0.loading = false
      $0.alert = .failed(.apiError(URLError(.cannotFindHost)))
    }
  }
}
