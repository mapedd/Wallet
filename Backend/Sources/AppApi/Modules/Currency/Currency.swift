//
//  Currency.swift
//  
//
//  Created by Tomek Kuzma on 07/01/2023.
//

import Foundation

public enum Currency {
  public struct List: Codable {
    
    var code: Code
    var name: String
    var namePlural: String
    var symbol: String
    var symbolNative: String
    
    public init(
      code: Currency.Code,
      name: String,
      namePlural: String,
      symbol: String,
      symbolNative: String
    ) {
      self.code = code
      self.name = name
      self.namePlural = namePlural
      self.symbol = symbol
      self.symbolNative = symbolNative
    }
  }
  
  public typealias Code = String
}
