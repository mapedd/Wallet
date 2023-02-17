//
//  VaporTestSession.swift
//  
//
//  Created by Tomek Kuzma on 11/02/2023.
//

import Foundation
import WalletCore
import Vapor
import XCTVapor


class VaporWebSocket: URLSessionWebSocketTaskProtocol {
  
  var app: Vapor.Application
  
  init(app: Vapor.Application) {
    self.app = app
  }
  
  var code: URLSessionWebSocketTask.CloseCode = .noStatusReceived
  var closeCode: URLSessionWebSocketTask.CloseCode {
    code
  }
  
  func resume() {
    if code == .noStatusReceived {
      code = .invalid
    }
  }
  
  func receive() async throws -> URLSessionWebSocketTask.Message {
    return .string("")
  }
  
  func send(_ message: URLSessionWebSocketTask.Message) async throws {
    
  }
}

struct VaporTestSession: URLSessionProtocol {
  
  let app: Vapor.Application
  
  init(app: Vapor.Application) {
    self.app = app
  }
  
  func webSocket(with url: URL) -> URLSessionWebSocketTaskProtocol {
    VaporWebSocket(app: app)
  }
  
  func data(
    for request: URLRequest
  ) async throws -> (Data, URLResponse) {
    
    let method: () -> Vapor.HTTPMethod  = {
      guard let httpMethod = request.httpMethod else { return .GET }
      switch httpMethod {
      case "GET":
        return .GET
      case "POST":
        return .POST
      default:
        return .GET
      }
    }
    
    let path: () -> String = {
      request.url?.path ?? ""
    }
    
    var output: (Data, URLResponse) = (.init(), .init())
    let testPath = path()
    let testMethod = method()
    
    try app.test(testMethod, testPath, beforeRequest: { req in
      if let bearer = request.allHTTPHeaderFields?["Authorization"] {
        let bearerCleared = bearer.replacingOccurrences(of: "Bearer ", with: "")
        req.headers.bearerAuthorization = BearerAuthorization(token: bearerCleared)
      }
      if
        let body = request.httpBody
      {
        req.body =  makeBody(body)
        req.headers.contentType = .json
      }
    }, afterResponse: { res in
      let body: Vapor.Response.Body = Vapor.Response.Body(buffer: res.body)
      if let data = body.data {
        output.0 = data
        output.1 = URLResponse(url: request.url!, mimeType: "", expectedContentLength: 123, textEncodingName: "")
      }
    })
    //      guard let output = output else {
    //        XCTFail("Record create failed")
    //        throw Abort(.internalServerError)
    //      }
    return output
  }
}

func makeBody(_ data: Data) -> ByteBuffer {
  var buffer: ByteBuffer = ByteBuffer.init(.init())
  buffer.writeBytes(data)
  return buffer
}

