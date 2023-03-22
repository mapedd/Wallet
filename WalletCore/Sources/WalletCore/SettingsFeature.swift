//
//  SettingsFeature.swift
//  
//
//  Created by Tomek Kuzma on 21/03/2023.
//

import Foundation
import ComposableArchitecture
import WalletCoreDataModel

public struct UserModel: Hashable, Identifiable {
  public init(email: String, id: UUID) {
    self.email = email
    self.id = id
  }
  
  public var email: String
  public var id: UUID
}

public struct Settings: ReducerProtocol {
  public init() {}
  public struct State: Hashable, Identifiable {
    
    public var id: UUID {
      self.user.id
    }
    
    public init(user: UserModel) {
      self.user = user
    }
    
    public var user: UserModel
    public var alert: AlertState<Action.Alert>? = nil
    
    public var headerCopy: String {
      "Logged in as \(user.email)"
    }
    
    
    public var isLoggedIn: Bool {
      true
    }
    
  }
  
  public enum Action: Equatable {
    case logOutButtonTapped
    case deleteAccountRowTapped
    case importFromFileRowTapped
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    public enum Alert: Equatable {
      case logoutAlertConfirmed
      case deleteAccountAlertConfirmed
    }
    public enum Delegate: Equatable {
      case logOutRequested
      case deleteAcountRequested
    }
  }
  
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .logOutButtonTapped:
      state.alert = .alertRequested
      return .none
    case .deleteAccountRowTapped:
      state.alert = .deleteAccount
      return .none
    case .importFromFileRowTapped:
      // show picker
      return .none
    case .alert(.presented(.logoutAlertConfirmed)):
      return Effect(value: .delegate(.logOutRequested))
    case .delegate:
      return .none
    case .alert(.dismiss):
      return .none
    case .importFromFileRowTapped:
      return .none
    case .alert(.presented(.deleteAccountAlertConfirmed)):
      return Effect(value: .delegate(.deleteAcountRequested))
    }
  }
}


extension AlertState where Action == Settings.Action.Alert {
  static var alertRequested: Self {
    AlertState {
      TextState("Logout")
    } actions: {
      ButtonState(role: .destructive, action: .send(.logoutAlertConfirmed, animation: .default)) {
        TextState("Yes")
      }
    } message: {
      TextState("Are you sure you want to log out?")
    }
  }
  
  static var deleteAccount: Self {
    AlertState {
      TextState("DANGER ZONE")
        .bold()
        .foregroundColor(.red)
    } actions: {
      ButtonState(role: .destructive, action: .send(.deleteAccountAlertConfirmed, animation: .default)) {
        TextState("Yes")
      }
    } message: {
      TextState("Are you sure you want to delete your account?")
    }
  }
}
//
//struct DataImporter {
//  struct Transaction {
//    let account: Account
//    let dates: Dates
//    let type: MoneyRecord.RecordType
//    let party: Party
//    let details: Details
//    let amounts: Amounts
//    let currency: Currency
//
//    struct Account {
//      let number: String
//    }
//
//    struct Dates {
//      let transaction: Date
//      let settlement: Date
//    }
//
//    struct Party {
//      let name: String
//    }
//
//    struct Details {
//      let description: String
//    }
//
//    struct Amounts {
//      let debited: Double?
//      let credited: Double?
//      let balance: Double
//    }
//
//    struct Currency {
//      let code: String
//    }
//  }
//  struct CSV {
//    func parseCSV(_ csvString: String) -> [Transaction]? {
//      var transactions = [Transaction]()
//
//      let lines = csvString.components(separatedBy: .newlines)
//
//      // Check if the CSV file has the expected header
//      let expectedHeader = "\"Numer rachunku/karty\",\"Data transakcji\",\"Data rozliczenia\",\"Rodzaj transakcji\",\"Na konto/Z konta\",\"Odbiorca/Zleceniodawca\",\"Opis\",\"Obciążenia\",\"Uznania\",\"Saldo\",\"Waluta\""
//
//      guard lines.count > 1 && lines[0] == expectedHeader else {
//        return nil
//      }
//
//      let df = DateFormatter()
//      //2023-03-20
//      df.dateFormat = "yyyy-MM-dd"
//
//      // Parse each line of the CSV file and create a Transaction struct
//      for line in lines.dropFirst() {
//        let fields = line.components(separatedBy: ",")
//
//        guard fields.count == 11 else {
//          continue
//        }
//
//        let accountNumber = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard let transactionDate = df.date(from: fields[1].trimmingCharacters(in: .whitespacesAndNewlines)) else {
//          continue
//        }
//
//        guard let settlementDate = df.date(from: fields[2].trimmingCharacters(in: .whitespacesAndNewlines)) else {
//          continue
//        }
//
//        let type: (_ fields: [String]) -> MoneyRecord.RecordType = { line in
//          if fields[7].count == 0 {
//            return .expense
//          } else {
//            return .income
//          }
//        }
//
//        let transaction = Transaction(
//          account: .init(number: accountNumber),
//          dates: .init(
//            transaction: transactionDate,
//            settlement: settlementDate
//          ),
//          type: type(fields),
//          party: .init(
//            name: fields[5]
//          ),
//          details: .init(
//            description: fields[6]
//          ),
//          amounts: .init(
//            debited: Double(fields[7]),
//            credited: Double(fields[8]),
//            balance: Double(fields[9])!
//          ),
//          currency: .init(code: fields[10])
//        )
//        transactions.append(transaction)
//
//      }
//
//      return transactions
//
//    }
//  }
//}
//
//
//let data = try String(contentsOfFile: path, encoding: .utf8)
//
