//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 07/01/2023.
//

import Vapor
import FluentKit
import AppApi

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
    let url: URI = "https://api.freecurrencyapi.com/v1/latest"
    let apiKey = "IQRoPuHyC37OgfvjK037aRfxcWm99roenKYE2jOE"
    
    let response = try await req.client.get(url) { req in
        try req.query.encode([
          "apikey": apiKey,
          "base_currency" : currencyQuery.baseCurrency.uppercased(),
          "currencies" : currencyQuery.currencies.joined(separator: ",")
        ])
    }
    
    do {
      let mappedResponse = try response.content.decode(ConversionResult.self)
      return mappedResponse
    } catch {
      req.logger.error("error \(error)")
      throw Abort(.internalServerError)
    }
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
