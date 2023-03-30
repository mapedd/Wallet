//
//  APIClient.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import Foundation
import AppApi
import WalletCoreDataModel

public struct APIClient {
  
  public var serverAddress: String
  
  public var signIn: (User.Account.Login) async throws -> User.Token.Detail?
  public var signOut: () async throws -> ActionResult
  public var register: (User.Account.Login) async throws -> User.Account.Detail?
  public var resendEmailConfirmation: (String) async throws -> ActionResult
  public var deleteAccount: () async throws -> ActionResult
  
  public var updateRecord: (AppApi.Record.Update) async throws -> AppApi.Record.Detail?
  public var listRecords: () async throws -> [AppApi.Record.Detail]
  
  public var createCategory: (AppApi.RecordCategory.Create) async throws -> AppApi.RecordCategory.Detail
  public var listCategories: () async throws -> [AppApi.RecordCategory.Detail]
  
  public var listCurrencies: () async throws -> [AppApi.Currency.List]
  public var conversions: (Currency.Code) async throws -> ConversionResult
  
  public var recordsChanged: () -> AsyncThrowingStream<UUID, Swift.Error>
  public var subscribeToRecordChanges: (UUID) async throws -> Void
}
