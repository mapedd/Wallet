//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 08/03/2023.
//

import XCTest
import ComposableArchitecture
import XCTestDynamicOverlay
import AppApi
import WalletCore

@MainActor
final class ContentFeatureTests: XCTestCase {
  func testLogOutDisabledAtLaunch() async throws {
    let store = TestStore(
      initialState: Content.State.loggedOut(.init()),
      reducer: Content()
    ) {
      $0.keychain = .preview
    }
    
    XCTAssertEqual(store.state.logOutCommandDisabled, true)
    await store.send(.task)
    XCTAssertEqual(store.state.logOutCommandDisabled, true)
  }
  
  func testLogOutEnabledIfHasCredentialsSavedInKeychain() async throws {
    let keychain = Keychain.preview
    let store = TestStore(
      initialState: Content.State.loggedOut(.init()),
      reducer: Content()
    ) {
      $0.keychain = keychain
    }
    
    keychain.saveToken(Token(value: "value", validDate: Date(), refreshToken: "refresh"))
    await store.send(.task) {
      $0 = .loggedIn(Main.State())
    }
    XCTAssertEqual(store.state.logOutCommandDisabled, false)
  }
  
  func testLogOutEnabledWhenWeLogIn() async throws {
    let keychain = Keychain.preview
    let tokenDetail = User.Token.Detail(
      id: .init(),
      token: .init(
        value: "value",
        expiry: Date(),
        refresh: "refresh"
      ),
      user: .init(
        id: .init(),
        email: "email"
      )
    )
    let store = TestStore(
      initialState: Content.State.loggedOut(.init()),
      reducer: Content()
    ) {
      $0.keychain = keychain
      $0.apiClient.signIn = { _ in
          tokenDetail
      }
    }
    
//    keychain.saveToken(Token(value: "value", validDate: Date(), refreshToken: "refresh"))
    await store.send(.loggedOut(.loggedIn(tokenDetail))) {
      $0 = .loggedIn(Main.State())
    }
    XCTAssertEqual(store.state.logOutCommandDisabled, false)
  }
}
