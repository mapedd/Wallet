//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 23/03/2023.
//

import Foundation
import ArgumentParser
import AppApi
import WalletCoreDataModel

extension AppApi.Record.Detail {
  init(_ transaction: DataImporter.Transaction) {
    self.init(
      id: .init(),
      title: transaction.details.description,
      amount: transaction.currentAmount,
      type: transaction.type,
      currencyCode: transaction.currency.code,
      created: transaction.dates.transaction,
      updated: transaction.dates.settlement
    )
  }
}

extension Import {
  
  struct Millenium: ParsableCommand {
    
    @OptionGroup var options: Import.Options
    
    mutating func run() throws {
      let csvString = try stringFromFile(at: options.inputFile)
      let transactions = try DataImporter.CSV.parseCSV(
        processor: .millenium,
        csvString: csvString
      )
      let records = transactions.map { transaction in
        AppApi.Record.Detail(transaction)
      }
      
      let jsonString = try records.convertToJSONString()
      
      print("JSON output \(jsonString)")
      
      if let output = options.outputFile {
        try export(jsonString: jsonString, to: output)
      }
    }
  }

}

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
