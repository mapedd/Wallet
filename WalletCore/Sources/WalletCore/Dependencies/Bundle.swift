//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 08/03/2023.
//

import Foundation
import Dependencies


public enum InfoDictionaryKey: DependencyKey {
  public static let liveValue: [String:Any] = Bundle.main.infoDictionary!
  public static let previewValue: [String: Any] = [BuildNumberKey:"1", AppVersionKey:"1.0.0"]
  public static let testValue: [String: Any] = [BuildNumberKey:"1", AppVersionKey:"1.0.0"]
}

extension DependencyValues {
  public var infoDictionary: [String:Any] {
    get { self[InfoDictionaryKey.self] }
    set { self[InfoDictionaryKey.self] = newValue }
  }
}
