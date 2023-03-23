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


extension Import {
  
  struct Revolut: ParsableCommand {
    
    @OptionGroup var options: Import.Options
    
    mutating func run() throws {
      let csvString = try stringFromFile(at: options.inputFile)
      let transactions = try DataImporter.CSV.parseCSV(
        processor: .revolut,
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
