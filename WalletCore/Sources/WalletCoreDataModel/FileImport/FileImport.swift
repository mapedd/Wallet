//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 22/03/2023.
//

import Foundation
import AppApi
import Parsing

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
  enum Error: Swift.Error {
    case notEnoughLines(minimum: Int)
    case invalidNumberOfFields(expected: Int, got: Int, at: Int)
    case wrongDateFormat(key: String, current: String, expected: String)
    
    var localizedDescription: String {
      switch self {
      case .wrongDateFormat(key: let key, current: let current, expected: let expected):
        return "Wrong date format for \(key), expected: \(expected), got: \(current)"
      case .notEnoughLines(let min):
        return "File should have at least \(min) lines"
      case .invalidNumberOfFields(let value, let actual, let index):
        return "Each line should have exactly \(value) fields, but line \(index) has \(actual) fields"
      }
    }
    
  }
  public struct Processor {
    
    private static var csvParser: AnyParser<Substring.UTF8View,[[String]]> {
      
      let plainField = Prefix { $0 != .init(ascii: ",") && $0 != .init(ascii: "\n") }

        let quotedField = ParsePrint {
          "\"".utf8
          Prefix { $0 != .init(ascii: "\"") }
          "\"".utf8
        }

        let field = OneOf {
          quotedField
          plainField
        }
        .map(.string)

        let line = Many {
          field
        } separator: {
          ",".utf8
        }

        let csv = Many {
          line
        } separator: {
          "\n".utf8
        } terminator: {
          End()
        }
      
      return csv.eraseToAnyParser()
    }
    
    public static var millenium: Processor {
      
      
      
      let df = DateFormatter()
      //2023-03-20
      df.dateFormat = "yyyy-MM-dd"
      print("string \(df.string(from: Date()))")
      
      let csv = Self.csvParser
      
      return Processor(
        parseStructure: { string in
          try csv.parse(string)
        },
        linesValidation: { lines in
          guard lines.count > 1 else {
            throw Error.notEnoughLines(minimum: 2)
          }
        },
        lineSeparator: "\n\n",
        skipLine: { line in
          return line.isEmpty
        },
        fieldSeparater: ",",
        fieldsValidation: { fields, i in
          guard fields.count == 11 else {
            throw Error.invalidNumberOfFields(expected: 11, got: fields.count, at: i)
          }
        },
        fieldPreprocessor: {
          $0.unwrapping(from: "\"")
        },
        lineTransformer: { fields, i in
          
          
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
          
          return transaction
        }
      )
    }
    
    public static var revolut: Processor {
      //  "Type,Product,Started Date,Completed Date,Description,Amount,Fee,Currency,State,Balance"
      //   TOPUP,Current,2020-03-02 15:24:16,2020-03-02 15:24:49,Top-Up by *3933,1000.00,0.00,PLN,COMPLETED,1000.72
      
      
      let df = DateFormatter()
      //2023-03-20
      df.dateFormat = "yyyy-MM-dd HH:mm:ss"
      print("string \(df.string(from: Date()))")
      
      let csv = Self.csvParser
      
      return Processor(
        parseStructure: { input in
          try csv.parse(input)
        },
        linesValidation: { lines in
          guard lines.count > 1 else {
            throw Error.notEnoughLines(minimum: 2)
          }
        },
        lineSeparator: "\n",
        skipLine: { line in
          return line == [""]
        },
        fieldSeparater: ",",
        fieldsValidation: { fields, i in
          guard fields.count == 10 else {
            throw Error.invalidNumberOfFields(expected: 10, got: fields.count, at: i)
          }
        },
        fieldPreprocessor: { $0 },
        lineTransformer: { fields, i in
          return Transaction(
            account: .init(number: fields[1]),
            dates: .init(
              transaction: df.date(from: fields[2])!,
              settlement: df.date(from: fields[3])!
            ),
            type: .expense,
            party: .init(name: ""),
            details: .init(description: fields[4]),
            amounts: .init(
              debited: 1,
              credited: 1,
              balance: Double(fields[9]) ?? .zero
            ),
            currency: .init(code: fields[7])
          )
        }
      )
    }
    
    public let parseStructure: (String) throws -> [[String]]
    public let linesValidation: (_ lines: [[String]]) throws -> Void
    public let lineSeparator: String
    public let skipLine: (_ line: [String]) -> Bool
    public let fieldSeparater: String
    public let fieldsValidation: (_ fields: [String], _ lineIndex: Int) throws -> Void
    public let fieldPreprocessor: (_ field: String) -> String
    public let lineTransformer: (_ fields:[String], _ lineIndex: Int) throws -> Transaction
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
    
    public static func parseCSV(
      processor: Processor,
      csvString: String
    ) throws ->  [Transaction] {
      var transactions = [Transaction]()
      
      let lines = try processor.parseStructure(csvString)
      
      try processor.linesValidation(lines)
      
      for (i,line) in lines.dropFirst().enumerated() {
        if processor.skipLine(line) {
          continue
        }
        
        let processedFields = line.map {
          processor.fieldPreprocessor($0)
        }
        try processor.fieldsValidation(processedFields, i)
        let transaction = try processor.lineTransformer(processedFields, i)
        transactions.append(transaction)
      }
    
      
      return transactions
      
    }
  }
}
