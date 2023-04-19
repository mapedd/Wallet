//
//  APIClient+Preview.swift
//  
//
//  Created by Tomek Kuzma on 15/02/2023.
//

import Foundation
import AppApi

extension APIClient {
  static var preview: APIClient {
    .init(
      serverAddress: "preview",
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
      resendEmailConfirmation: { _ in
        .init(success: true)
      },
      deleteAccount: {
        .init(success: true)
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
      },
      recordsChanged: {
        AsyncThrowingStream { _ in }
      },
      subscribeToRecordChanges: { _ in
        
      }
    )
  }
}
