//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 22/03/2023.
//

import Foundation
import AppApi

public extension String {
  func unwrapping(from suffixAndPrefix: String) -> String {
    var string = self
    if string.hasSuffix(suffixAndPrefix) {
      string = String(string.dropLast(suffixAndPrefix.count))
    }
    if string.hasPrefix(suffixAndPrefix) {
      string = String(string.dropFirst(suffixAndPrefix.count))
    }
    return string
  }
}

public struct DataImporter {
  public struct Processor {
    public static let millenium = Processor()
  }
  public struct Transaction: CustomStringConvertible {
    public var description: String {
      "amount \(amounts), date: \(dates)"
    }
    public let account: Account
    public let dates: Dates
    public let type: RecordType
    public let party: Party
    public let details: Details
    public let amounts: Amounts
    public let currency: Currency
    
    public var currentAmount: Decimal {
      if let expense = amounts.debited {
        return Decimal(expense)
      }
      if let income = amounts.credited {
        return Decimal(income)
      }
      return .zero
    }
    
    public struct Account {
      public let number: String
    }
    
    public struct Dates: CustomStringConvertible {
      public let transaction: Date
      public let settlement: Date
      
      public var description: String {
        let df = DateFormatter()
        //2023-03-20
        df.dateFormat = "yyyy-MM-dd"
        return "transaction date: \(df.string(from: transaction)), settlement date: \(df.string(from: settlement))"
      }
    }
    
    public struct Party {
      public let name: String
    }
    
    public struct Details {
      public let description: String
    }
    
    public struct Amounts: CustomStringConvertible {
      public let debited: Double?
      public let credited: Double?
      public let balance: Double
      
      public var description: String {
        if let debited {
          return "-\(String(format: "%.2f", debited)) balance: \(String(format: "%.2f", balance))"
        } else if let credited {
          return "+\(String(format: "%.2f", credited)) balance: \(String(format: "%.2f", balance))"
        }
        return "balance: \(String(format: "%.2f", balance))"
      }
    }
    
    public struct Currency {
      public let code: String
    }
  }
  public struct CSV {
    enum Error: Swift.Error {
      case notEnoughLines
      case wrongDateFormat(key: String, current: String, expected: String)
      
      var localizedDescription: String {
        switch self {
        case .wrongDateFormat(key: let key, current: let current, expected: let expected):
          return "Wrong date format for \(key), expected: \(expected), got: \(current)"
        case .notEnoughLines:
          return "File shuld have at least 2 lines"
        }
      }
      
    }
    public static func parseCSV(
      processor: Processor,
      csvString: String
    ) throws ->  [Transaction] {
      var transactions = [Transaction]()
      
      let lines = csvString.components(separatedBy: .newlines)
      
      
      guard lines.count > 1 else {
        print("not enough lines")
        throw Error.notEnoughLines
      }
      
      let df = DateFormatter()
      //2023-03-20
      df.dateFormat = "yyyy-MM-dd"
      print("string \(df.string(from: Date()))")
      
      // Parse each line of the CSV file and create a Transaction struct
      for (i,line) in lines.dropFirst().enumerated() {
        let fields = line.components(separatedBy: ",").map { string in
          string.unwrapping(from: "\"")
        }
        
        guard fields.count == 11 else {
          continue
        }
        
        let accountNumber = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
        
        let tDateString = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let transactionDate = df.date(from: tDateString) else {
          throw Error.wrongDateFormat(key: "transactionDate", current: tDateString, expected: df.dateFormat)
        }
        
        let sDateString = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
        guard let settlementDate = df.date(from: sDateString) else {
          throw Error.wrongDateFormat(key: "settlementDate", current: sDateString, expected: df.dateFormat)
        }
        
        let type: (_ fields: [String]) -> RecordType = { line in
          if fields[7].count == 0 {
            return .expense
          } else {
            return .income
          }
        }
        
        print("index \(i)")
        for (j,field) in fields.enumerated() {
          print("   \(j) \(field)")
        }
        
        let transaction = Transaction(
          account: .init(number: accountNumber),
          dates: .init(
            transaction: transactionDate,
            settlement: settlementDate
          ),
          type: type(fields),
          party: .init(
            name: fields[5]
          ),
          details: .init(
            description: fields[6]
          ),
          amounts: .init(
            debited: Double(fields[7]),
            credited: Double(fields[8]),
            balance: Double(fields[9]) ?? .zero
          ),
          currency: .init(code: fields[10])
        )
        transactions.append(transaction)
        
      }
      
      return transactions
      
    }
  }
}
//
//let path = Bundle.main.path(forResource: "history", ofType: "csv")!
//let data = try String(contentsOfFile: path, encoding: .utf8)
//let transactions = try DataImporter.CSV().parseCSV(data)
//
//print("transactions \(transactions.map(\.description).joined(separator: "\n"))")
