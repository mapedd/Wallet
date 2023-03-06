//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 01. 08..
//

@testable import App
import XCTVapor
import FluentKit

class AppTestCase: XCTestCase {
  
  struct UserLogin: Content {
    let email: String
    let password: String
    
    static let tomBob = UserLogin(email: "tom@bob.com", password: "abc")
  }
  
  func createTestApp(dateProvider: DateProvider = .init(currentDate: { Date() })) throws -> Application {
    let app = Application(.testing)
    
    do {
      try configure(app, dateProvider: dateProvider)
      try app.autoMigrate().wait()
    }
    catch {}
    return app
  }
  
  func update(
    record input: Record.Update,
    app: Application,
    token: User.Token.Detail
  ) async throws -> Record.Detail {
    var recordOutput: Record.Detail?
    try app.test(.POST, "/api/record/update", beforeRequest: { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: token.token.value)
      try req.content.encode(input)
    }, afterResponse: { res in
      XCTAssertContent(Record.Detail.self, res) { content in
        recordOutput = content
      }
    })
    guard let recordOutput = recordOutput else {
      XCTFail("Record create failed")
      throw Abort(.internalServerError)
    }
    return recordOutput
  }
  
  func register(_ userLogin: UserLogin, _ app: Application) throws -> User.Account.Detail {
    var user: User.Account.Detail?
    try app.test(.POST, UserRouter.Route.register.path, beforeRequest: { req in
      try req.content.encode(userLogin)
    }, afterResponse: { res in
      XCTAssertContent(User.Account.Detail.self, res) { content in
        user = content
      }
    })
    guard let result = user else {
      XCTFail("Register failed")
      throw Abort(.unauthorized)
    }
    return result
  }
  
  func authenticate(_ user: UserLogin, _ app: Application) throws -> User.Token.Detail {
    var token: User.Token.Detail?
    try app.test(.POST, "/api/sign-in/", beforeRequest: { req in
      try req.content.encode(user)
    }, afterResponse: { res in
      XCTAssertContent(User.Token.Detail.self, res) { content in
        token = content
      }
    })
    guard let result = token else {
      XCTFail("Login failed")
      throw Abort(.unauthorized)
    }
    return result
  }
  
  func signOut(_ token: String, _ app: Application) throws -> ActionResult {
    var result: ActionResult?
    try app.test(.GET, "/api/sign-out/", beforeRequest: { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: token)
    }, afterResponse: { res in
      XCTAssertContent(ActionResult.self, res) { content in
        result = content
      }
    })
    guard let result = result else {
      XCTFail("Login failed")
      throw Abort(.unauthorized)
    }
    return result
  }
  
  func authenticateRoot(_ app: Application) throws -> User.Token.Detail {
    try authenticate(.init(email: "root@localhost.com", password: "ChangeMe1"), app)
  }
  
  func registerAndSignInUser(
    app: Application,
    login: UserLogin = .tomBob
  ) async throws -> User.Token.Detail {
    primeForReceivingClientRequests(app)
    let _ = try register(login, app)
    return try authenticate(login, app)
  }
  
  lazy var customClient: CustomClient = {
    let client = CustomClient()
    client.responseGenerator = { req in 
      return ClientResponse(
        status: .ok,
        headers: HTTPHeaders(),
        body: nil,
        byteBufferAllocator: ByteBufferAllocator()
      )
    }
    return client
  }()
  
  // this mocks client on the application that can be used to do requestes to
  // external resources
  func primeForReceivingClientRequests(_ app: Application) {
    let provider = Application.Clients.Provider.custom
    app.storage[Application.CustomClientKey.self] = self.customClient
    app.clients.use(provider)
  }
}

