//
//  URLSession+URLSessionProtocol.swift
//  
//
//  Created by Tomek Kuzma on 15/02/2023.
//

import Foundation


extension URLSession: URLSessionProtocol {
  public func data(
    for request: URLRequest
  ) async throws -> (Data, URLResponse) {
    try await data(for: request, delegate: nil)
  }
  
  public func webSocket(with url: URL) -> URLSessionWebSocketTaskProtocol {
    self.webSocketTask(with: url)
  }
}

extension URLSessionWebSocketTask : URLSessionWebSocketTaskProtocol {
  
}
