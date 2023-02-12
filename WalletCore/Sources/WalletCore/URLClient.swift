//
//  URLClient.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 04/02/2023.
//

import Foundation


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
  let session: URLSessionProtocol
  var tokenProvider: TokenProvider?
//  var task: URLSessionWebSocketTask

  init(
    baseURL: URL,
    session: URLSessionProtocol,
    tokenProvider: TokenProvider?
  ) {
    self.baseURL = baseURL
    self.session = session
    self.tokenProvider = tokenProvider

//    let websocket = URL(string: "wss://demo.piesocket.com/v3/channel_123?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV")!
//    let websocket = URL(string: "ws://localhost:8080/api/websocket")!
//    let websocket = URL(string: "ws://127.0.0.1:8080/records/websocket")!
//    let websocket = URL(string: "ws://127.0.0.1:8080")!
//    self.task = session.webSocketTask(with: websocket)
//    self.task.resume()
//
//    task.receive { receive in
//      print("received \(receive)")
//    }
//
//
//    Timer.scheduledTimer(
//      withTimeInterval: 3,
//      repeats: true
//    ) {[weak self] timer in
//      let message = URLSessionWebSocketTask.Message.string("hi I'm the client")
//
//      self?.task.send(message) { error in
//        if let error {
//          print("sending ws message failed \(String(describing: error))")
//        }
//      }
//    }

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
    
    do {
      let data = try await fetchData(request: request(from: endpoint))
      let elapsed = CFAbsoluteTimeGetCurrent() - start
      let formatted = String(format: "%.2f seconds", elapsed)
      debugPrint("[\(endpoint.httpMethod.rawValue)]: \(endpoint.path) \(formatted) ")
      
      
      do {
        return try decoder.decode(T.self, from: data)
      } catch {
        if let backendError = try? decoder.decode(BackendError.self, from: data) {
          throw backendError
        }
        throw error
      }
    } catch {
      throw error
    }
    
  }
  
  struct BackendError: Error, Codable {
    var message: String
    var details: [String]
    
    var readableDescription: String {
      String(describing: self)
    }
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
