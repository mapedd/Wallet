//
//  APIClient.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import Foundation
import AppApi
import XCTestDynamicOverlay

public struct APIClient {
  
  public var signIn: (User.Account.Login) async throws -> User.Token.Detail?
  public var signOut: () async throws -> ActionResult
  public var register: (User.Account.Login) async throws -> User.Account.Detail?
  public var updateRecord: (AppApi.Record.Update) async throws -> AppApi.Record.Detail?
  public var listRecords: () async throws -> [AppApi.Record.Detail]
  
  public var createCategory: (AppApi.RecordCategory.Create) async throws -> AppApi.RecordCategory.Detail
  public var listCategories: () async throws -> [AppApi.RecordCategory.Detail]
  
  public var listCurrencies: () async throws -> [AppApi.Currency.List]
  public var conversions: (Currency.Code) async throws -> ConversionResult
  
}

public protocol URLSessionProtocol {
  func data(
    for request: URLRequest
  ) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
  public func data(
    for request: URLRequest
  ) async throws -> (Data, URLResponse) {
    try await data(for: request, delegate: nil)
  }
}

extension APIClient {
  public static var live: APIClient {
    .live(keychain: .live, session: URLSession.shared)
  }
  public static func live(
    keychain: Keychain,
    session: URLSessionProtocol
  ) -> APIClient {
    
    let url = URL(string: "http://localhost:8080/api/")!
    
    let authURLClient = URLClient(
      baseURL: url,
      session: session,
      tokenProvider: nil
    )
    
    let authNetwork = AuthNetwork(
      refreshToken: { refreshToken in
        authURLClient.tokenProvider = .init(
          bearerToken: {
            keychain.readToken()?.value
          },
          refreshToken: {}
        )
        // handle refresh token getting 401
        let endpoint = Endpoint.auth(.refreshToken(.init(refresh: refreshToken)))
        let apiToken: User.Token.Detail = try await authURLClient.fetch(endpoint: endpoint)
        return apiToken.toLocalToken
      }
    )
    
    let authManager = AuthManager.init(
      keychain: keychain,
      authNetwork: authNetwork,
      dateProvider: .init(
        currentDate: { Date() }
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
        try await urlClient.fetch(endpoint: Endpoint.auth(.signIn(login)))
      },
      signOut: {
        try await urlClient.fetch(endpoint: Endpoint.auth(.signOut))
      },
      register: { login in
        try await urlClient.fetch(endpoint: Endpoint.auth(.register(login)))
      },
      updateRecord: { record in
        try await urlClient.fetch(endpoint: Endpoint.record(.updateRecord(record)))
      },
      listRecords: {
        try await urlClient.fetch(endpoint: Endpoint.record(.listRecords))
      },
      createCategory: { create in
        try await urlClient.fetch(endpoint: Endpoint.category(.create(create)))
      },
      listCategories: {
        try await urlClient.fetch(endpoint: Endpoint.category(.list))
      },
      listCurrencies: {
        try await urlClient.fetch(endpoint: Endpoint.currency(.list))
      },
      conversions: { code in
        try await urlClient.fetch(endpoint: Endpoint.currency(.conversions(base: code, currencies: [])))
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
      register: { _ in
          .init(
            id: UUID(),
            email: "email"
          )
      },
      updateRecord: {
        .init(
          id: $0.id,
          title: $0.title,
          amount: $0.amount,
          type: .expense,
          currencyCode: "usd",
          created: Date(),
          updated: $0.updated
        )
      },
      listRecords: {
        []
      },
      createCategory: { _ in
          .init(id: UUID(), name: "category name", color: 123)
      },
      listCategories: {
        [
          .init(id: .init(), name: "Fun", color: 1),
          .init(id: .init(), name: "Sweets", color: 3)
        ]
      },
      listCurrencies: {
        [
          .init(code: "USD", name: "Dollar", namePlural: "Dollars", symbol: "$", symbolNative: "$")
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
      register: {_ in
        XCTFail("unimplemented")
        return nil
      },
      updateRecord: { _ in
        XCTFail("unimplemented")
        return nil
      },
      listRecords: {
        XCTFail("unimplemented")
        return []
      },
      createCategory: { _ in
        XCTFail("unimplemented")
        return .init(id: .init(), name: "", color: -1)
      },
      listCategories: {
        XCTFail("unimplemented")
        return []
      },
      listCurrencies: {
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
