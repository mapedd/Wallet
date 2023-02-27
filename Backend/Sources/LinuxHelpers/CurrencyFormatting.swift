//
//  CurrencyFormatting.swift
//  
//
//  Created by Tomek Kuzma on 27/02/2023.
//

import Foundation

public extension Decimal {
  func formatted(currency code: String) -> String {
    
    let safeImplementation: (String) -> String = { code in
      let numberFormatter = NumberFormatter()
      numberFormatter.currencyCode = code
      if let formatted = numberFormatter.string(from: NSDecimalNumber(decimal: self)) {
        return formatted
      } else {
        return "\(code) \(self)"
      }
    }
    
    if #available(iOS 15.0, *) {
      return self.formatted(.currency(code: code))
    }
    else {
#if canImport(Darwin)
      return safeImplementation(code)
#else
      return safeImplementation(code)
#endif
    }
  }
}
