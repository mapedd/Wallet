//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 25/03/2023.
//

import Foundation
import ComposableArchitecture

public struct DocumentPicker: ReducerProtocol {
  public init() {}
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    .none
  }
  
  public struct State: Hashable, Identifiable {
    public let id = UUID()
  }
  public enum Action: Equatable {
    
  }
  
}
