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
  public let value: String
  public let validDate: Date
  public let refreshToken: String

  var encodable: Encodable {
    .init(token: self)
  }

  func isValid(_ now: Date) -> Bool {
    validDate > now
  }

  @objc(WalletToken) class Encodable: NSObject, NSCoding {

    var token: Token?

    init(token: Token) {
      self.token = token
    }

    required init?(coder decoder: NSCoder) {
      guard
        let value = decoder.decodeObject(forKey: "value") as? String,
        let validDate = decoder.decodeObject(forKey: "validDate") as? Date,
        let refreshToken = decoder.decodeObject(forKey: "refreshToken") as? String
      else { return nil }
      token = Token(value: value, validDate: validDate, refreshToken: refreshToken)
    }

    func encode(with encoder: NSCoder) {
      encoder.encode(token?.value, forKey: "value")
      encoder.encode(token?.validDate, forKey: "validDate")
      encoder.encode(token?.refreshToken, forKey: "refreshToken")
    }
  }
}

