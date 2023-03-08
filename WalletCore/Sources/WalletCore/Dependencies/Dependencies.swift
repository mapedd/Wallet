//
//  Dependencies.swift
//  Wallet
//
//  Created by Tomek Kuzma on 01/01/2023.
//

import Foundation
import ComposableArchitecture
import Logging


private enum LoggerKey: DependencyKey {
  static let liveValue = Logger(label: "com.mapedd.wallet")
}

extension DependencyValues {
  public var logger: Logger {
    get { self[LoggerKey.self] }
    set { self[LoggerKey.self] = newValue }
  }
}

private enum APIClientKey: DependencyKey {
  static let liveValue = APIClient.live
  static let previewValue = APIClient.preview
  static let testValue = APIClient.test
}

extension DependencyValues {
  public var apiClient: APIClient {
    get { self[APIClientKey.self] }
    set { self[APIClientKey.self] = newValue }
  }
}

private enum DateProviderKey: DependencyKey {
  static let liveValue = DateProvider.live
  static let previewValue = DateProvider.preview
}

extension DependencyValues {
  var dateProvider: DateProvider {
    get { self[DateProviderKey.self] }
    set { self[DateProviderKey.self] = newValue }
  }
}

private enum KeyValueStoreProviderKey: DependencyKey {
  static let liveValue = KeyValueStore.live
  static let previewValue = KeyValueStore.preview
}

extension DependencyValues {
  public var keyValueStore: KeyValueStore {
    get { self[KeyValueStoreProviderKey.self] }
    set { self[KeyValueStoreProviderKey.self] = newValue }
  }
}

private enum KeychainKey: DependencyKey {
  static let liveValue = Keychain.live
  static let previewValue = Keychain.preview
}

extension DependencyValues {
  public var keychain: Keychain {
    get { self[KeychainKey.self] }
    set { self[KeychainKey.self] = newValue }
  }
}
