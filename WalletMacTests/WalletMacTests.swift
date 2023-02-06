//
//  WalletMacTests.swift
//  WalletMacTests
//
//  Created by Tomek Kuzma on 06/02/2023.
//

import XCTest
import ComposableArchitecture
@testable import Wallet_Mac

final class WalletMacTests: XCTestCase {
  func testInit() {
    let _ = TestStore(
      initialState: .init(),
      reducer: Login(),
      prepareDependencies: { _ in }
    )
  }
}
