//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 07/01/2023.
//

import Vapor
import FluentKit
import AppApi

enum CacheKey {
  case conversions(ConversionsQuery)
  
  var rawValue: String {
    switch self {
    case .conversions(let query):
      if query.currencies.isEmpty {
        return "currency.conversions-\(query.baseCurrency)"
      } else {
        return "currency.conversions-\(query.baseCurrency)-\(query.currencies.joined(separator: "-"))"
      }
    }
  }
}

extension Vapor.Cache {
  func `get`<T>(_ key: CacheKey) async throws -> T? where T: Decodable {
    return try await self.get(key.rawValue)
  }
  func set<T>(_ key: CacheKey, to value: T?) async throws where T: Encodable {
    try await self.set(key.rawValue, to: value, expiresIn: .seconds(5)).get()
  }
  
}


extension Request {
  func conversions(query: ConversionsQuery) async throws -> ConversionResult {
        
    if let cached: ConversionResult = try await cache.get(.conversions(query)) {
      logger.info("returning cached currency conversions")
      return cached
    }
    
    let url: URI = "https://api.freecurrencyapi.com/v1/latest"
    let apiKey = "IQRoPuHyC37OgfvjK037aRfxcWm99roenKYE2jOE"
    
    let response = try await client.get(url) { req in
        try req.query.encode([
          "apikey": apiKey,
          "base_currency" : query.baseCurrency.uppercased(),
          "currencies" : query.currencies.joined(separator: ",")
        ])
    }
    
    do {
      let mappedResponse = try response.content.decode(ConversionResult.self)
      
      try await cache.set(.conversions(query),to: mappedResponse)
      
      return mappedResponse
    } catch {
      logger.error("error \(error)")
      throw Abort(.internalServerError)
    }
  }
}

struct ConversionResult: Content {
  var data: [String:Float]
}

struct ConversionsQuery: Content {
  var baseCurrency: String
  var currencies: [String]
}

extension Currency.List : Content {}

struct CurrencyAPIController {
  
  var dateProvider: DateProvider
  
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
  }
  
  enum External {
    struct Currency: Codable {
      var symbol: String
      var name: String
      var symbol_native: String
      var decimal_digits : Int
      var rounding : Int
      var code: String
      var name_plural : String
    }
    
    struct ListResponse: Codable {
      var data: [String: Currency]
    }
  }
  
  func conversions(req: Request) async throws -> ConversionResult {
    let currencyQuery = try req.query.decode(ConversionsQuery.self)
    return try await req.conversions(query: currencyQuery)
  }
  
  
  func list(req: Request) async throws -> [Currency.List] {
    let url: URI = "https://api.freecurrencyapi.com/v1/currencies"
    let apiKey = "IQRoPuHyC37OgfvjK037aRfxcWm99roenKYE2jOE"
    let response = try await req.client.get(url) { req in
        try req.query.encode(["apikey": apiKey])
    }
    
    do {
      let mappedResponse = try response.content.decode(External.ListResponse.self)
      
  //    errors are like this:
  //    - key : "message"
  //    - value : "No API key found in request"
      
      var currencies = [Currency.List]()
      
      for dataDict in mappedResponse.data.values {
        currencies.append(.init(
          code: dataDict.code,
          name: dataDict.name,
          namePlural: dataDict.name_plural,
          symbol: dataDict.symbol,
          symbolNative: dataDict.symbol_native
        ))
      }
      
      return currencies
    } catch {
      req.logger.error("error \(error)")
      throw Abort(.internalServerError)
    }
    
  }
}
