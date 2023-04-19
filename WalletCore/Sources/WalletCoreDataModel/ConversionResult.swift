//
//  ConversionResult.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation

public struct ConversionResult: Hashable, Codable {
  public init(data: [String : Float]) {
    self.data = data
  }
  
  public var data: [String:Float]
}

