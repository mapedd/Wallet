//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 22/03/2023.
//

import Foundation
import ArgumentParser
import AppApi
import WalletCoreDataModel

@main
struct Import: ParsableCommand {
  
  @Argument(help: "The csv file name to import and export as internal JSON format")
  var inputFile: String
  
  @Argument(help: "The csv file name to export inpout in the internal JSON format")
  var outputFile: String?
  
  mutating func run() throws {
    
    let data = try String(contentsOfFile: inputFile, encoding: .utf8)
    let transactions = try DataImporter.CSV.parseCSV(data)
    let records = transactions.map { transaction in
      AppApi.Record.Detail(
        id: .init(),
        title: transaction.details.description,
        amount: transaction.currentAmount,
        type: transaction.type,
        currencyCode: transaction.currency.code,
        created: transaction.dates.transaction,
        updated: transaction.dates.settlement
      )
    }
    
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let outputData = try encoder.encode(records)
    let jsonString = String(data: outputData, encoding: .utf8)
    
    guard let jsonString else {
      throw ValidationError("Cannot convert transactions to records JSON format")
    }
    
    print("JSON outpout \(jsonString)")
    if let outputFile {
      try outputFile.write(toFile: outputFile, atomically: true, encoding: .utf8)
    }
    
  }
}
