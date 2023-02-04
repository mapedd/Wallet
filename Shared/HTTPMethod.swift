//
//  HTTPMethod.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation


enum HTTPMethod {
  case GET
  case POST(Encodable?)

  var rawValue: String {
    switch self {
    case .GET:
      return "GET"
    case .POST:
      return "POST"
    }
  }
}
