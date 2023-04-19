//
//  Token.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation


struct TokenProvider {
  var bearerToken : () async throws -> String?
  var refreshToken: () async throws -> Void
}


public struct Token: Codable, Sendable {
  
  public init(
    value: String,
    validDate: Date,
    refreshToken: String
  ) {
    self.value = value
    self.validDate = validDate
    self.refreshToken = refreshToken
  }
  
  public let value: String
  public let validDate: Date
  public let refreshToken: String
  

  func isValid(_ now: Date) -> Bool {
    validDate > now
  }
}

