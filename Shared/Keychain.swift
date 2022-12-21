//
//  Keychain.swift
//  AMLHUB
//
//  Created by Tomasz Kuzma on 03/10/2022.
//

import Foundation
import SwiftKeychainWrapper

struct Keychain {

	private enum Key: String, CaseIterable {
		case token = "com.mapedd.wallet.token"
	}
  
  var saveToken: (Token?) -> Void
  var readToken: () -> Token?

	func removeAll() {
    saveToken(nil)
	}

	static var live: Keychain {
		let wrapper = KeychainWrapper.standard

		return Keychain(
      saveToken: { token in
        if let token {
          wrapper.set(token.encodable, forKey: Key.token.rawValue)
        } else {
          wrapper.remove(forKey: KeychainWrapper.Key(rawValue: Key.token.rawValue))
        }
      },
      readToken: {
        guard
          let encodable = wrapper.object(forKey: Key.token.rawValue) as? Token.Encodable
        else {
          return nil
        }
        return encodable.token
      }
		)
	}
	
	static var loggedIn: Keychain {
    var data: [Key: Any] = [
      Key.token : Token(value: "dasd", validDate: .init(), refreshToken: "dasd"),
		]
		
		return Keychain(
			saveToken: { token in
        data[.token] = token
      },
      readToken: {
        data[.token] as? Token
      }
		)
	}

	static var preview: Keychain {
    var data: [Key: Any] = [:]
    
    return Keychain(
      saveToken: { token in
        data[.token] = token
      },
      readToken: {
        data[.token] as? Token
      }
    )
	}
	
}
