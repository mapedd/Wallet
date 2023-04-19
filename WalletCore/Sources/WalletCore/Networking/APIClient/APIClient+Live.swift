//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 15/02/2023.
//

import Foundation
import AppApi

extension APIClient {
  
  public static var live: APIClient {
    .live(
      keychain: .live,
      session: URLSession.shared
    )
  }
  
  public static func live(
    keychain: Keychain,
    session: URLSessionProtocol
  ) -> APIClient {
    
//    let url = URL(string: "http://www.portfelmapedd.online/api/")!
//    let url = URL(string: "http://192.168.1.7:8080/api/")!
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
      serverAddress: url.absoluteString,
      signIn: { login in
        try await urlClient.fetch(endpoint: Endpoint.auth(.signIn(login)))
      },
      signOut: {
        try await urlClient.fetch(endpoint: Endpoint.auth(.signOut))
      },
      register: { login in
        try await urlClient.fetch(endpoint: Endpoint.auth(.register(login)))
      },
      resendEmailConfirmation: { email in
        try await urlClient.fetch(endpoint: Endpoint.auth(.resendEmailConfirmation(email)))
      },
      deleteAccount: {
        try await urlClient.fetch(endpoint: Endpoint.auth(.deleteAccount))
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
      },
      recordsChanged: {
        streamOfChangedRecords(task: urlClient.websocketTask)
      },
      subscribeToRecordChanges: { userId in
        try await subscribeToRecordChange(userId: userId, task: urlClient.websocketTask)
      }
    )
  }
  
  static func subscribeToRecordChange(
    userId: UUID,
    task: URLSessionWebSocketTaskProtocol
  ) async throws {
    
    
    let message = WebsocketMessage(
      client: userId,
      data:  Websocket.Connect(id: userId, connect: true)
    )
    
    let _enoder = JSONEncoder()
    do {
      let data = try _enoder.encode(message)
      try await task.send(.data(data))
    } catch {
      throw error
    }
  }
  
  static func receiveHandler(
    task: URLSessionWebSocketTaskProtocol,
    continuation: @escaping (Data) -> Void
  ) async {
    var isActive = true
    
    while isActive && task.closeCode == .invalid {
      do {
        let message = try await task.receive()
        
        switch message {
        case let .string(string):
          print(string)
        case let .data(data):
          continuation(data)
        @unknown default:
          print("unkown message received")
        }
      } catch {
        print(error)
        isActive = false
      }
    }
  }
  
  static func streamOfChangedRecords(
    task: URLSessionWebSocketTaskProtocol
  ) -> AsyncThrowingStream<UUID, Swift.Error> {
    AsyncThrowingStream { continuation in
      Task {
        await receiveHandler(task: task) { data in
          let decoder = JSONDecoder()
          if let update = try? decoder.decode(WebsocketMessage<Websocket.RecordUpdate>.self, from: data) {
            continuation.yield(update.data.id)
          }
        }
      }
    }
  }
  
  //  static func streamOfChangedRecords(task: URLSessionWebSocketTask) -> AsyncThrowingStream<UUID, Swift.Error> {
  //    AsyncThrowingStream { continuation in
  //      task.receive { receive in
  //        print("received \(receive)")
  //        switch receive {
  //        case .failure(let error):
  //          continuation.finish(throwing: error)
  //        case .success(.data(let data)):
  //          let decoder = JSONDecoder()
  //          if let update = try? decoder.decode(WebsocketMessage<Websocket.RecordUpdate>.self, from: data) {
  //            continuation.yield(update.data.id)
  //          }
  //        case .success(.string(_)):
  //          continuation.finish()
  //        case .success(_):
  //          continuation.finish()
  //        }
  //      }
  //    }
  //  }
}
