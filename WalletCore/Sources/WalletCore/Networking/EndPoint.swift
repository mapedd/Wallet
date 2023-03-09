//
//  EndPoint.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation
import AppApi
import Utils


extension String {
  func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
}

extension String {
  
  func adding(query items: [URLQueryItem]) -> String {
    var components = URLComponents(string: self)
    let safeItems = items.map {
      URLQueryItem(
        name: $0.name,
        value: $0.value?.stringByAddingPercentEncodingForRFC3986()
      )
    }
    components?.queryItems = safeItems
    return components!.url!.absoluteString
  }
}


enum Endpoint {
  enum Currency {
    case list
    case conversions(base: String, currencies: [String])
    
    var httpMethod: HTTPMethod {
      return .GET
    }
    
    var path: String {
      switch self {
      case .list:
        return "currency/list"
      case .conversions(let base, let currencies):
        
//        var items = [
//          URLQueryItem(name: "baseCurrency", value: base)
//        ]
//        if !currencies.isEmpty {
//          items.append(
//            URLQueryItem(name: "currencies", value: currencies.joined(separator: ","))
//          )
//        }
        
        let items = Array {
          URLQueryItem(name: "baseCurrency", value: base)
          if !currencies.isEmpty {
            URLQueryItem(name: "currencies", value: currencies.joined(separator: ","))
          }
        }
        
        return "currency/conversions".adding(query: items)
      }
    }
  }
  enum Category {
    case list
    case create(AppApi.RecordCategory.Create)
    
    var httpMethod: HTTPMethod {
      switch self {
      case .create(let create):
        return .POST(create)
      case .list:
        return .GET
      }
    }
    
    var path: String {
      switch self {
      case .list:
        return "record/category/list"
      case .create:
        return "record/category/create"
      }
    }
  }
  
  enum Record {
    case updateRecord(AppApi.Record.Update)
    case listRecords
    
    var httpMethod: HTTPMethod {
      switch self {
      case .updateRecord(let record):
        return .POST(record)
      case .listRecords:
        return .GET
      }
    }
    
    var path: String {
      switch self {
      case .listRecords:
        return "record/list"
      case .updateRecord:
        return "record/update"
      }
    }
  }
  
  enum Auth {
    
    case signIn(User.Account.Login)
    case signOut
    case register(User.Account.Login)
    case refreshToken(User.Token.Refresh)
    case resendEmailConfirmation(String)
    
    var isAuthenticated: Bool {
      switch self {
      case .signIn, .register, .resendEmailConfirmation:
        return false
      default:
        return true
      }
    }
    
    var httpMethod: HTTPMethod {
      switch self {
      case .signIn(let login):
        return .POST(login)
      case .register(let login):
        return .POST(login)
      case .refreshToken(let token):
        return .POST(token)
      case .signOut:
        return .GET
      case .resendEmailConfirmation:
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
      case .resendEmailConfirmation(let email):
        let items = [URLQueryItem(name: "email", value: email)]
        return "resend".adding(query: items)
      }
    }
  }
  
  case auth(Auth)
  case record(Record)
  case currency(Currency)
  case category(Category)
  
  var httpMethod: HTTPMethod {
    switch self {
    case .auth(let auth):
      return auth.httpMethod
    case .record(let record):
      return record.httpMethod
    case .currency(let currency):
      return currency.httpMethod
    case .category(let category):
      return category.httpMethod
    }
  }
  
  var path: String {
    switch self {
    case .auth(let auth):
      return auth.path
    case .record(let record):
      return record.path
    case .currency(let currency):
      return currency.path
    case .category(let category):
      return category.path
    }
  }
  
  var isAuthenticated: Bool {
    switch self {
    case .auth(let auth):
      return auth.isAuthenticated
    default:
      return true
    }
  }
}
