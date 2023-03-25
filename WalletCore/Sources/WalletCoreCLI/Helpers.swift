//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 23/03/2023.
//

import Foundation
import ArgumentParser
import AppApi

extension Array where Element == AppApi.Record.Detail {
  
  func convertToJSONString() throws -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let outputData = try encoder.encode(self)
    if let jsonString = String(data: outputData, encoding: .utf8) {
      return jsonString
    }
    
    throw ValidationError("Cannot convert transactions to records JSON format")
  }
}

extension ParsableCommand {
  
  func stringFromFile(at path: String) throws -> String {
    let expandedInputFilePath = path.expandingTildeInPath
    let string = try String(contentsOfFile: expandedInputFilePath, encoding: .utf8)
    return string
  }
  
  func export(jsonString: String, to outputFile: String) throws {
    try jsonString.write(toFile: outputFile, atomically: true, encoding: .utf8)
  }
}

extension String {
  var expandingTildeInPath: String {
      return self.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)
  }
}
