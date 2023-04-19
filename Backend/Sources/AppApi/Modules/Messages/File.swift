//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 13/02/2023.
//

import Foundation

public struct WebsocketMessage<T: Codable>: Codable {
  
  public init(
    client: UUID,
    data: T
  ) {
    self.client = client
    self.data = data
  }
  
  public let client: UUID
  public let data: T
  
}
