//
//  CustomClient.swift
//  
//
//  Created by Tomek Kuzma on 06/03/2023.
//

import Vapor


public final class CustomClient: Client {
  public var eventLoop: EventLoop {
    EmbeddedEventLoop()
  }
  public var requestsReceived = [ClientRequest]()
  public var responseGenerator: (ClientRequest) -> ClientResponse = { _ in
      .init()
  }
  
  public init() {
    
  }
  
  public func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
    self.requestsReceived.append(request)
    return self.eventLoop.makeSucceededFuture(responseGenerator(request))
  }
  
  public func delegating(to eventLoop: EventLoop) -> Client {
    self
  }
}

extension Application {
  public struct CustomClientKey: StorageKey {
    public typealias Value = CustomClient
  }
  
  public var customClient: CustomClient {
    if let existing = self.storage[CustomClientKey.self] {
      return existing
    } else {
      fatalError("custom client must be set here")
      //      let new = CustomClient()
      //      self.storage[CustomClientKey.self] = new
      //      return new
    }
  }
}

extension Application.Clients.Provider {
  public static var custom: Self {
    .init {
      $0.clients.use { $0.customClient }
    }
  }
}

