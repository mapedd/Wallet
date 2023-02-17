//
//  File.swift
//  Wallet
//
//  Created by Tomek Kuzma on 01/01/2023.
//

import Foundation

public struct KeyValueStore {
  var write: (_ key: String, _ value: String) -> Void
  var read: (_ key: String) -> String?
  
  static var live: KeyValueStore {
    let defaults = UserDefaults.standard
    return KeyValueStore(
      write: {key, value in
        defaults.set(value, forKey: key)
      },
      read: { key in
        defaults.value(forKey: key) as? String
      }
    )
  }
  
  static var preview: KeyValueStore {
    var dict = [String: String]()
    return KeyValueStore(
      write: {key, value in
        dict[key] = value
      },
      read: { key in
        dict[key]
      }
    )
  }
}
