//
//  AuthManager.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation


struct AuthNetwork {
  var refreshToken: (String) async throws -> Token
}

enum AuthError: Error {
  case unauthorized // refreshing token failed
  case missingRefreshToken // expiryDate lapsed but cannot find refresh token
  case tokenExpired // expiryDate is lapsed
  case noTokenStored // default state
}

actor AuthManager {

  init(
    keychain: Keychain,
    authNetwork: AuthNetwork,
    dateProvider: DateProvider
  ) {
    self.keychain = keychain
    self.authNetwork = authNetwork
    self.dateProvider = dateProvider
  }

  private let dateProvider: DateProvider
  private let keychain: Keychain
  private let authNetwork: AuthNetwork
  private var currentToken: Token? {
    set {
      keychain.saveToken(newValue)
    }
    get {
      keychain.readToken()
    }
  }
  private var refreshTask: Task<Token, Error>?

  func validToken() async throws -> Token {
    if let handle = refreshTask {
      return try await handle.value
    }

    guard let token = currentToken else {
      throw AuthError.noTokenStored /// this means we need to login
    }

    if token.isValid(dateProvider.now) {
      return token
    }

    return try await refreshToken(token: token.refreshToken)
  }

  func tryRefreshCurrentToken() async throws -> Void {
    guard let refresh = currentToken?.refreshToken else {
      throw AuthError.missingRefreshToken
    }
    let _ = try await refreshToken(token: refresh)
  }

  private func refreshToken(token: String) async throws -> Token {
    if let refreshTask = refreshTask {
      return try await refreshTask.value
    }

    let task = Task { () throws -> Token in
      defer { refreshTask = nil }

      let newToken = try await authNetwork.refreshToken(token)

      currentToken = newToken

      return newToken
    }

    self.refreshTask = task

    return try await task.value
  }
}
