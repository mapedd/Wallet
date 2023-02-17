//
//  DateProvider.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation

public struct DateProvider {
  public init(currentDate: @escaping () -> Date) {
    self.currentDate = currentDate
  }
  
  public var currentDate: () -> Date

  public var now: Date {
    currentDate()
  }

  public static let live = DateProvider {
    .now
  }

  public static let preview = DateProvider.live
}
