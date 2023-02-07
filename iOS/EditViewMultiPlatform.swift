//
//  EditViewMultiPlatform.swift
//  Wallet (iOS)
//
//  Created by Tomasz Kuzma on 20/09/2022.
//

import SwiftUI
import WalletCore

extension Main.State.EditMode {
  var iOSEditMode: SwiftUI.EditMode {
    switch self {
    case .active:
      return SwiftUI.EditMode.active
    case .transient:
      return SwiftUI.EditMode.transient
    case .inactive:
      return SwiftUI.EditMode.inactive
    }
  }
}

extension SwiftUI.EditMode {
  var walletEditMode: Main.State.EditMode {
    switch self {
    case .active:
      return Main.State.EditMode.active
    case .transient:
      return Main.State.EditMode.transient
    case .inactive:
      return Main.State.EditMode.inactive
    @unknown default:
      fatalError()
    }
  }
}
