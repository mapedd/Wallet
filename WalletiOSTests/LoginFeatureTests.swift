//
//  LoginFeatureTests.swift
//  WalletiOSTests
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import XCTest
@testable import Wallet_IOS
import ComposableArchitecture
import XCTestDynamicOverlay
import AppApi

@MainActor
final class LoginFeatureTests: XCTestCase {
  func testDefaultEmailPasswordState() async {
    let userTokenDetail = User.Token.Detail(
      id: UUID(),
      token: .init(
        value: "value",
        expiry: Date(),
        refresh: "refresh"
      ),
      user: .init(
        id: UUID(),
        email: "email"
      )
    )
    let store = TestStore(
      initialState: .init(),
      reducer: Login(),
      prepareDependencies: { _ in }
    )
    store.dependencies.apiClient.signIn = { _ in
      userTokenDetail
    }
    await store.send(.logIn) {
      $0.loading = true
    }
    await store.receive(.loggedIn(userTokenDetail), timeout: .seconds(1)) {
      $0.loading = false
    }
  }
}
