//
//  APIClient.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import Foundation
import AppApi

enum HTTPMethod {
  case GET
  case POST(Encodable?)
  
  var rawValue: String {
    switch self {
    case .GET:
      return "GET"
    case .POST:
      return "POST"
    }
  }
}


struct Token: Codable, Sendable {
  let value: String
  let validDate: Date
  let refreshToken: String
  
  var encodable: Encodable {
    .init(token: self)
  }
  
  func isValid(_ now: Date) -> Bool {
    validDate > now
  }
  
  @objc(WalletToken) class Encodable: NSObject, NSCoding {
    
    var token: Token?
    
    init(token: Token) {
      self.token = token
    }
    
    required init?(coder decoder: NSCoder) {
      guard
        let value = decoder.decodeObject(forKey: "value") as? String,
        let validDate = decoder.decodeObject(forKey: "validDate") as? Date,
        let refreshToken = decoder.decodeObject(forKey: "refreshToken") as? String
      else { return nil }
      token = Token(value: value, validDate: validDate, refreshToken: refreshToken)
    }
    
    func encode(with encoder: NSCoder) {
      encoder.encode(token?.value, forKey: "value")
      encoder.encode(token?.validDate, forKey: "validDate")
      encoder.encode(token?.refreshToken, forKey: "refreshToken")
    }
  }
}

struct AuthNetwork {
  var refreshToken: (String) async throws -> Token
}

enum AuthError: Error {
  case unauthorized // refreshing token failed
  case missingRefreshToken // expiryDate lapsed but cannot find refresh token
  case tokenExpired // expiryDate is lapsed
  case noTokenStored // default state
}

struct DateProvider {
  var currentDate: () -> Date
  
  var now: Date {
    currentDate()
  }
}

actor AuthManager {
  
  init(
    keychain: Keychain,
    authNetwork: AuthNetwork,
    dateProvider: DateProvider
  ) {
    self.keychain = keychain
    self.authNetwork = authNetwork
    self.dateProvider = dateProvider
  }
  
  private let dateProvider: DateProvider
  private let keychain: Keychain
  private let authNetwork: AuthNetwork
  private var currentToken: Token? {
    set {
      keychain.saveToken(newValue)
    }
    get {
      keychain.readToken()
    }
  }
  private var refreshTask: Task<Token, Error>?
  
  func validToken() async throws -> Token {
    if let handle = refreshTask {
      return try await handle.value
    }
    
    guard let token = currentToken else {
      throw AuthError.noTokenStored /// this means we need to login
    }
    
    if token.isValid(dateProvider.now) {
      return token
    }
    
    return try await refreshToken(token: token.refreshToken)
  }
  
  func tryRefreshCurrentToken() async throws -> Void {
    guard let refresh = currentToken?.refreshToken else {
      throw AuthError.missingRefreshToken
    }
    let _ = try await refreshToken(token: refresh)
  }
  
  private func refreshToken(token: String) async throws -> Token {
    if let refreshTask = refreshTask {
      return try await refreshTask.value
    }
    
    let task = Task { () throws -> Token in
      defer { refreshTask = nil }
      
      let newToken = try await authNetwork.refreshToken(token)
      
      currentToken = newToken
      
      return newToken
    }
    
    self.refreshTask = task
    
    return try await task.value
  }
}


enum Endpoint {
  case signIn(User.Account.Login)
  case signOut
  case refreshToken(User.Token.Refresh)
  case updateRecord(Record.Update)
  case listRecords
  
  var httpMethod: HTTPMethod {
    switch self {
    case .signIn(let login):
      return .POST(login)
    case .refreshToken(let token):
      return .POST(token)
    case .updateRecord(let record):
      return .POST(record)
    case .listRecords:
      return .GET
    case .signOut:
      return .GET
    }
  }
  
  var path: String {
    switch self {
    case .signOut:
      return "sign-out/"
    case .signIn:
      return "sign-in/"
    case .refreshToken:
      return "refresh-token/"
    case .listRecords:
      return "record/list"
    case .updateRecord:
      return "record/update"
    }
  }
  
  var isAuthenticated: Bool {
    switch self {
    case .signIn:
      return false
    default:
      return true
    }
  }
}

struct TokenProvider {
  var bearerToken : () async throws -> String?
  var refreshToken: () async throws -> Void
}

class URLClient {
  
  lazy var encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()
  
  lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()
  
  let baseURL: URL
  let session: URLSession
  var tokenProvider: TokenProvider?
  
  init(
    baseURL: URL,
    session: URLSession,
    tokenProvider: TokenProvider?
  ) {
    self.baseURL = baseURL
    self.session = session
    self.tokenProvider = tokenProvider
  }
  
  func request(
    from endPoint: Endpoint
  ) async throws -> URLRequest {
    var request = URLRequest(url: URL(string: endPoint.path, relativeTo: baseURL)!)
    if
      case let .POST(encodable) = endPoint.httpMethod,
      let encodable
    {
      request.httpBody = try encoder.encode(encodable)
    }
    request.httpMethod = endPoint.httpMethod.rawValue
    if let tokenProvider, endPoint.isAuthenticated {
      let token = try await tokenProvider.bearerToken()
      if let token {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
  }
  
  func fetch<T: Decodable>(
    endpoint: Endpoint
  ) async throws -> T {
    let start = CFAbsoluteTimeGetCurrent()
    let data = try await fetchData(request: request(from: endpoint))
    let elapsed = CFAbsoluteTimeGetCurrent() - start
    let formatted = String(format: "%.2f seconds", elapsed)
    debugPrint("[\(endpoint.httpMethod.rawValue)]: \(endpoint.path) \(formatted) ")
    return try decoder.decode(T.self, from: data)
  }
  
  private func fetchData(
    request: URLRequest,
    allowRetry: Bool = true
  ) async throws -> Data {
    do {
      
      let (data, urlResponse) = try await session.data(for:request)
      
      // check the http status code and refresh + retry if we received 401 Unauthorized
      if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 401 {
        if let tokenProvider, allowRetry {
          try await tokenProvider.refreshToken()
          let (data, _) = try await session.data(for:request)
          return data
        }
        
        throw AuthError.unauthorized
      }
      
      
      return data
    } catch {
      throw error
    }
  }
}

struct APIClient {
  
  var signIn: (User.Account.Login) async throws -> User.Token.Detail?
  var signOut: () async throws -> ActionResult
  var updateRecord: (Record.Update) async throws -> Record.Detail?
  var listRecords: () async throws -> [Record.Detail]
  
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
      }
    )
  }
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
          title: $0.title ?? "",
          amount: $0.amount ?? .init(1),
          currency: .pln,
          created: .now,
          updated: $0.updated
        )
      },
      listRecords: {
        []
      }
    )
  }
}
