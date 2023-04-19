//
//  URLSessionProtocol.swift
//  
//
//  Created by Tomek Kuzma on 15/02/2023.
//

import Foundation


public protocol URLSessionProtocol {
  func data(
    for request: URLRequest
  ) async throws -> (Data, URLResponse)
  
  func webSocket(with url: URL) -> URLSessionWebSocketTaskProtocol
}

public protocol URLSessionWebSocketTaskProtocol {
  func resume()
  func receive() async throws -> URLSessionWebSocketTask.Message
  func send(_ message: URLSessionWebSocketTask.Message) async throws
  var closeCode: URLSessionWebSocketTask.CloseCode { get }
}
