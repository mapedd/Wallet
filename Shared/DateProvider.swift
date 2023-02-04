//
//  DateProvider.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation

struct DateProvider {
  var currentDate: () -> Date

  var now: Date {
    currentDate()
  }

  static let live = DateProvider {
    .now
  }

  static let preview = DateProvider.live
}
