//
//  Keychain.swift
//  AMLHUB
//
//  Created by Tomasz Kuzma on 03/10/2022.
//

import Foundation
import KeychainAccess

public struct Keychain {

	private enum Key: String, CaseIterable {
		case token = "com.mapedd.wallet.token"
	}
  
  public var saveToken: (Token?) -> Void
  public var readToken: () -> Token?

  public func removeAll() {
    saveToken(nil)
	}
  
  public static func live(name: String?) -> Keychain {
    
    let wrapper: KeychainAccess.Keychain
    
    if let name {
      wrapper = KeychainAccess.Keychain(service: name)
    } else {
      wrapper = KeychainAccess.Keychain()
    }
    
    let encoder = PropertyListEncoder()
    let decoder = PropertyListDecoder()
    
    
    return Keychain(
      saveToken: { token in
        if let token {
          do {
            let data = try encoder.encode(token)
            wrapper[data: Key.token.rawValue] = data
          } catch {
            
          }
        } else {
          wrapper[data: Key.token.rawValue] = nil
        }
      },
      readToken: {
        guard
          let data = wrapper[data: Key.token.rawValue]
        else {
          return nil
        }
        
        do {
          return try decoder.decode(Token.self, from: data)
        } catch {
          return nil
        }
      }
    )
  }

  public static var live: Keychain {
    return live(name: nil)
	}
	
  public static var loggedIn: Keychain {
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

  public static var preview: Keychain {
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
