//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 01. 07..
//

import Foundation

public extension User {
  
  enum Token: ApiModelInterface {
    public typealias Module = User
  }
}

public extension User.Token {
  
  struct Refresh: Codable {
    public let refresh: String
    public init(refresh: String) {
      self.refresh = refresh
    }
  }
  
  struct Detail: Codable {
    public let id: UUID
    public let token: Value
    public let user: User.Account.Detail
    
    public init(
      id: UUID,
      token: Value,
      user: User.Account.Detail
    ) {
      self.id = id
      self.token = token
      self.user = user
    }
  }
  
  struct Value: Codable {
    public let value: String
    public let expiry: Date
    public let refresh: String
    
    public init(
      value: String,
      expiry: Date,
      refresh: String
    ) {
      self.value = value
      self.expiry = expiry
      self.refresh = refresh
    }
    
  }
}

public struct ActionResult: Codable {
  public init(success: Bool) {
    self.success = success
  }
  public var success: Bool
}
