//
//  RecordCategory.swift
//  
//
//  Created by Tomek Kuzma on 03/01/2023.
//


import Foundation

public enum RecordCategory {}

public extension RecordCategory {
  struct Detail: Codable,Hashable {
    
    public init(
      id: UUID,
      name: String,
      color: Int
    ) {
      self.id = id
      self.name = name
      self.color = color
    }
    
    public var id: UUID
    public var name: String
    public var color: Int
  }
  
  struct Create: Codable,Hashable {
    
    public init(
      name: String,
      color: Int
    ) {
      self.name = name
      self.color = color
    }
    
    public var name: String
    public var color: Int
  }
}

