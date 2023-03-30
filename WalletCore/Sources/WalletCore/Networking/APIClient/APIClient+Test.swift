//
//  APIClient+Test.swift
//  
//
//  Created by Tomek Kuzma on 15/02/2023.
//

import Foundation
import XCTestDynamicOverlay


extension APIClient {
  static var test: APIClient {
    .init(
      serverAddress: "",
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
      resendEmailConfirmation: { _ in
        XCTFail("unimplemented")
        return .init(success: false)
      },
      deleteAccount: {
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
      },
      recordsChanged: {
        XCTFail("unimplemented")
        return AsyncThrowingStream { _ in }
      },
      subscribeToRecordChanges: { _ in
        XCTFail("unimplemented")
      }
    )
  }
}
