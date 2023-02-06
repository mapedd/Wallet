//
//  EndPoint.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation
import AppApi


enum Endpoint {
  enum Currency {
    case list
    case conversions(base: String, currencies: [String])
  }
  case signIn(User.Account.Login)
  case signOut
  case register(User.Account.Login)
  case refreshToken(User.Token.Refresh)
  case updateRecord(AppApi.Record.Update)
  case listRecords
  case currency(Currency)
  case listCategories

  var httpMethod: HTTPMethod {
    switch self {
    case .signIn(let login):
      return .POST(login)
    case .register(let login):
      return .POST(login)
    case .refreshToken(let token):
      return .POST(token)
    case .updateRecord(let record):
      return .POST(record)
    case .listRecords:
      return .GET
    case .signOut:
      return .GET
    case .currency:
      return .GET
    case .listCategories:
      return .GET
    }
  }

  var path: String {
    switch self {
    case .signOut:
      return "sign-out/"
    case .signIn:
      return "sign-in/"
    case .register:
      return "register/"
    case .refreshToken:
      return "refresh-token/"
    case .listRecords:
      return "record/list"
    case .updateRecord:
      return "record/update"
    case .listCategories:
      return "record/category/list"
    case .currency(let endpoint):
      switch endpoint {
      case .list:
        return "currency/list"
      case .conversions(let base, let currencies):
          var components = URLComponents(string: "currency/conversions")
          var queryItems = [
            URLQueryItem(name: "baseCurrency", value: base)
          ]
          if !currencies.isEmpty {
              queryItems.append(
                URLQueryItem(name: "currencies", value: currencies.joined(separator: ","))
              )
          }
          components?.queryItems = queryItems
          return components!.url!.absoluteString
      }
    }
  }

  var isAuthenticated: Bool {
    switch self {
    case .signIn, .register:
      return false
    default:
      return true
    }
  }
}
