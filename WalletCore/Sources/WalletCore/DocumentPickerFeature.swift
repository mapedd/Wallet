//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 25/03/2023.
//

import Foundation
import ComposableArchitecture
import WalletCoreDataModel
import AppApi

public struct DocumentPicker: ReducerProtocol {
  public init() {}
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .selected(let urls):
        return .task(
          operation: {
            guard let firstURL = urls.first else {
              return .parsingFailed
            }
            let csvString = try String(contentsOf: firstURL, encoding: .utf8)
            let records = try DataImporter.CSV.parseToRecord(csvString: csvString)
            return .delegate(.attemptImport(records))
          },
          catch: { _ in
            return .parsingFailed
          }
        )
    case .parsingFailed:
      state.showProgress = false
      // need show some alert here
      return .none
    case .delegate:
      return .none
    }
  }
  
  public struct State: Hashable, Identifiable {
    public let id = UUID()
    public var showProgress = false
  }
  public enum Action: Equatable {
    case selected([URL])
    case delegate(Delegate)
    case parsingFailed
    
    public enum Delegate: Equatable {
      case attemptImport([AppApi.Record.Detail])
    }
  }
  
}
