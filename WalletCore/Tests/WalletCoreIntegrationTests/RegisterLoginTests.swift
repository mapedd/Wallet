//
//  RegisterLoginTests.swift
//  
//
//  Created by Tomek Kuzma on 08/02/2023.
//

import Foundation
import XCTest
import WalletCore
import Vapor
@testable import App
import XCTVapor
import AppApi
import AppTestingHelpers
import ComposableArchitecture


extension User.Account.Login {
  static var sample: Self {
    let date = Date()
    let email = "wallet+\(floor(date.timeIntervalSince1970))@example.com"
    return User.Account.Login(
      email: email,
      password: "tomek"
    )
  }
}
extension AppApi.Record.Update {
  static var sample: AppApi.Record.Update {
    .init(
      id: UUID(),
      title: "title",
      amount: .init(123.45),
      type: .expense,
      currencyCode: "PLN",
      notes: "notes",
      categoryIds: [],
      updated: Date(),
      deleted: nil
    )
  }
}

class RegisterLoginTests: APIIntegrationTest {
  
  class Harness {
    var app: Application
    var api: APIClient
    var keychain: Keychain
    
    init() {
      
      self.keychain = Keychain.preview
      self.app = try! Self.createTestApp()
      self.app.prepareCustomClient()
//
//      let client = CustomClient()
//      client.responseGenerator = { req in
//        return ClientResponse(
//          status: .ok,
//          headers: HTTPHeaders(),
//          body: nil,
//          byteBufferAllocator: ByteBufferAllocator()
//        )
//      }
//
//      let provider = Application.Clients.Provider.custom
//      app.storage[Application.CustomClientKey.self] = client
//      app.clients.use(provider)
      
      let session = VaporTestSession(app: app)
      self.api = APIClient.live(
        keychain: keychain,
        session: session
      )
    }
    
    static func createTestApp(
      dateProvider: App.DateProvider = .init(currentDate: { Date() })
    ) throws -> Application {
      let app = Application(.testing)
      
      do {
        try configure(app, dateProvider: dateProvider)
        try app.autoMigrate().wait()
      }
      catch {}
      return app
    }
    
    func createUserAndSignIn() async throws {
      let user = User.Account.Login.sample
      let _ = try await api.register(.sample)
      try await app.confirm(email: user.email)
      let login = try await api.signIn(user)
      if let login {
        keychain.saveToken(login.toLocalToken)
      }
    }
    
    deinit {
      app.shutdown()
    }
//    
//    // this will check sent external requests , get the message
//    // extract the deeplink and call that in
//    func confirm(email address: String) async throws {
//      let req = try XCTUnwrap(app.customClient.requestsReceived.first)
//      
//      let string = req.description
//      print(string)
//      
//      var sendEmail: MailerSendEmail.Request?
//      do {
//        sendEmail = try req.content.decode(MailerSendEmail.Request.self)
//      } catch {
//        XCTFail(error.localizedDescription)
//      }
//      
//      let sendEmailUnwrapped = try XCTUnwrap(sendEmail)
//      XCTAssertEqual(sendEmailUnwrapped.to.first!.email, address)
//      
//      let html = sendEmailUnwrapped.html
//      let doc: Document = try SwiftSoup.parse(html)
//      let link: Element = try doc.select("a").first()!
//      let linkHref: String = try link.attr("href")
//    
//      
//      let components = try XCTUnwrap(URLComponents(string: linkHref))
//      var path = components.path + "?"
//      for component in components.queryItems! {
//        path.append("\(component.name)=\(component.value!)")
//      }
//      
//      try app.test(.GET, path, afterResponse: { _ in })
//    }
  }
  
  func testRegisterSignInSignOut() async throws {
    let harness = Harness()
    let user = User.Account.Login.sample
    let response = try await harness.api.register(.sample)
    
    XCTAssertEqual(response?.email, user.email)
    
    try await harness.app.confirm(email: user.email)
    
    let login = try await harness.api.signIn(user)
    
    let loginValue = try XCTUnwrap(login)
    harness.keychain.saveToken(loginValue.toLocalToken)
    
    XCTAssertEqual(login?.user.email, user.email)
    
    let result = try await harness.api.signOut()
    
    XCTAssertTrue(result.success)
  }
  
  func testCreateRecord() async throws {
    let harness = Harness()
    try await harness.createUserAndSignIn()
    
    let record = AppApi.Record.Update.sample
    
    let newRecord = try await harness.api.updateRecord(record)
    
    XCTAssertNotNil(newRecord)
    
    let records = try await harness.api.listRecords()
    
    XCTAssert(records.count == 1)
    let first = try XCTUnwrap(records.first)
    XCTAssertEqual(first.title, "title")
    XCTAssertEqual(first.amount, Decimal(123.45))
    
  }
  
  func testCreateListCategory() async throws {
    let harness = Harness()
    try await harness.createUserAndSignIn()
    
    let newCategory = AppApi.RecordCategory.Create(name: "category_0", color: 123)
    
    let createdCategory = try await harness.api.createCategory(newCategory)
    
    XCTAssertEqual(createdCategory.name, "category_0")
    
    let categories = try await harness.api.listCategories()
    
    XCTAssertEqual(categories, [createdCategory])
  }
}


extension ClientRequest: CustomStringConvertible {
  public var description: String {
    var desc = [self.url.string]
    desc += self.headers.map { "\($0.name): \($0.value)" }
    if var body = self.body {
      let string = body.readString(length: body.readableBytes) ?? ""
      desc += ["", string]
    }
    return desc.joined(separator: "\n")
  }
}
