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
