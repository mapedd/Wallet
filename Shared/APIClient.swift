//
//  APIClient.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import Foundation
import AppApi
import XCTestDynamicOverlay

struct APIClient {
  
  var signIn: (User.Account.Login) async throws -> User.Token.Detail?
  var signOut: () async throws -> ActionResult
  var updateRecord: (AppApi.Record.Update) async throws -> AppApi.Record.Detail?
  var listRecords: () async throws -> [AppApi.Record.Detail]
  var listCurrencies: () async throws -> [AppApi.Currency.List]
  var listCategories: () async throws -> [AppApi.RecordCategory.Detail]
  var conversions: (Currency.Code) async throws -> ConversionResult


}
extension APIClient {
  static var live: APIClient {

    let session = URLSession.shared
    let url = URL(string: "http://localhost:8080/api/")!

    let authURLClient = URLClient(
      baseURL: url,
      session: session,
      tokenProvider: nil
    )

    let keychain = Keychain.live

    let authNetwork = AuthNetwork(
      refreshToken: { refreshToken in
        authURLClient.tokenProvider = .init(
          bearerToken: {
            keychain.readToken()?.value
          },
          refreshToken: {}
        )
        // handle refresh token getting 401
        let apiToken: User.Token.Detail = try await authURLClient.fetch(endpoint: .refreshToken(.init(refresh: refreshToken)))
        return apiToken.toLocalToken
      }
    )

    let authManager = AuthManager.init(
      keychain: keychain,
      authNetwork: authNetwork,
      dateProvider: .init(
        currentDate: { .now }
      )
    )

    let urlClient = URLClient(
      baseURL: url,
      session: session,
      tokenProvider: .init(
        bearerToken: {
          try await authManager.validToken().value
        },
        refreshToken: authManager.tryRefreshCurrentToken
      )
    )

    return APIClient(
      signIn: { login in
        try await urlClient.fetch(endpoint: .signIn(login))
      },
      signOut: {
        try await urlClient.fetch(endpoint: .signOut)
      },
      updateRecord: { record in
        try await urlClient.fetch(endpoint: .updateRecord(record))
      },
      listRecords: {
        try await urlClient.fetch(endpoint: .listRecords)
      },
      listCurrencies: {
        try await urlClient.fetch(endpoint: .currency(.list))
      },
      listCategories: {
        try await urlClient.fetch(endpoint: .listCategories)
      },
      conversions: { code in
        try await urlClient.fetch(endpoint: .currency(.conversions(base: code, currencies: [])))
      }
    )
  }
}

extension APIClient {
  static var mock: APIClient {
    .init(
      signIn: { _ in
        User.Token.Detail(
          id: .init(),
          token: .init(
            value: "token",
            expiry: .init(),
            refresh: "refresh"),
          user: .init(
            id: .init(),
            email: "asd")
        )
      },
      signOut: {
        ActionResult(success: true)
      },
      updateRecord: {
        .init(
          id: $0.id,
          title: $0.title,
          amount: $0.amount,
          type: .expense,
          currencyCode: "usd",
          created: .now,
          updated: $0.updated
        )
      },
      listRecords: {
        []
      },
      listCurrencies: {
        [
          .init(code: "USD", name: "Dollar", namePlural: "Dollars", symbol: "$", symbolNative: "$")
        ]
      },
      listCategories: {
        [
          .init(id: .init(), name: "Fun", color: 1),
          .init(id: .init(), name: "Sweets", color: 3)
        ]
      },
      conversions: { _ in
          .init(data: [String : Float]())
      }
    )
  }
}

extension APIClient {
  //  static var test: APIClient {
  //    .init(
  //      signIn: unimplemented("sign in is unimplemented"),
  //      signOut: unimplemented("sign in is unimplemented"),
  //      updateRecord: unimplemented()"sign in is unimplemented",
  //      listRecords: unimplemented("sign in is unimplemented"),
  //      listCurrencies: unimplemented("sign in is unimplemented"),
  //      listCategories: unimplemented("sign in is unimplemented"),
  //      conversions: unimplemented("sign in is unimplemented")
  //    )
  //  }
  static var test: APIClient {
    .init(
      signIn: { _ in
        XCTFail("unimplemented")
        return nil
      },
      signOut: {
        XCTFail("unimplemented")
        return .init(success: false)
      },
      updateRecord: { _ in
        XCTFail("unimplemented")
        return nil
      },
      listRecords: {
        XCTFail("unimplemented")
        return []
      },
      listCurrencies: {
        XCTFail("unimplemented")
        return []
      },
      listCategories: {
        XCTFail("unimplemented")
        return []
      },
      conversions: { _ in
        XCTFail("unimplemented")
        return .init(data: [String : Float]())
      }
    )
  }
}
