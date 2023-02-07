//
//  MoneyRecord+UI.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import UIKit
import WalletCore

extension MoneyRecord.RecordType {
  var color: UIColor {
    switch self {
    case .income:
      return .green
    case .expense:
      return .red
    }
  }
  var name: String {
    switch self {
    case .income:
      return "arrow.down.square.fill"
    case .expense:
      return "arrow.up.square.fill"
    }
  }
}
