//
//  EditViewMultiPlatform.swift
//  Wallet (iOS)
//
//  Created by Tomasz Kuzma on 20/09/2022.
//

import SwiftUI

extension MainState.EditMode {
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
  var walletEditMode: MainState.EditMode {
    switch self {
    case .active:
      return MainState.EditMode.active
    case .transient:
      return MainState.EditMode.transient
    case .inactive:
      return MainState.EditMode.inactive
    @unknown default:
      fatalError()
    }
  }
}
