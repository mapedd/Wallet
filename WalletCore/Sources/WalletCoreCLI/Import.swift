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

extension DataImporter.CSV {
  enum Format: String, ExpressibleByArgument, CaseIterable {
    case millenium
    case revolut
  }
}

struct Import: ParsableCommand {
  
  static var configuration = CommandConfiguration(
    commandName: "import",
    abstract: "A utility for transforming bank csv into JSON understood by Wallet Core."
  )
  
  
  @Argument(help: "The csv file name to import and export as internal JSON format")
  var inputFile: String

  @Argument(help: "The file name to export output in the internal JSON format")
  var outputFile: String?
//
  @Option(help: "The kind of average to provide.")
  var format: DataImporter.CSV.Format = .millenium
  
  func processor(from format: DataImporter.CSV.Format) -> DataImporter.Processor {
    switch format {
    case .millenium:
      return .millenium
    case .revolut:
      return .revolut
    }
  }
  
  mutating func run() throws {
    print(ProcessInfo().arguments)
    print("run import \(format)")
    let csvString = try stringFromFile(at: inputFile)
    let transactions = try DataImporter.CSV.parseCSV(
      processor: processor(from:format),
      csvString: csvString
    )
    let records = transactions.map { transaction in
      AppApi.Record.Detail(transaction:transaction)
    }

    let jsonString = try records.convertToJSONString()

    print("JSON output \(jsonString)")

    if let outputFile {
      try export(jsonString: jsonString, to: outputFile)
    }
  }
  
}
