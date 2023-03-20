//
//  StatisticsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture
import AppApi

extension MoneyRecord {
  func apply(filter: Statistics.State.Filter) -> Bool {
    switch filter {
    case .expenseType(let type):
      return type == self.type
    case .dateRange(let dateRange):
      return dateRange.apply(self.date)
    }
  }
}

public struct Statistics: ReducerProtocol {

  public init() {}
  
  public struct State: Equatable, Identifiable {
    
    public var id = UUID()
    
    public var records: IdentifiedArrayOf<MoneyRecord> = []
    public var filter: Filter = .expenseType(.expense)
    public var dateFilter: Filter = .dateRange(.thisWeek)
    public var showDateFilter = false
    public var baseCurrency: AppApi.Currency.Code
    
    public var formattedFilteredTotal: String {
      return filteredTotal.formatted(currency: baseCurrency)
    }
    
    public enum DateRange: Identifiable, Hashable, CaseIterable {
      public var id: String {
        self.stringValue
      }
      
      case today
      case thisYear
      case thisWeek
      case thisMonth
      
      
      case last3Months
      case last6Months
      case lastYear
      
      public var stringValue: String {
        switch self {
        case .today:
          return "Today"
        case .thisYear:
          return "This year"
        case .thisWeek:
          return "This week"
        case .thisMonth:
          return "This month"
        case .last3Months:
          return "Last 3 months"
        case .last6Months:
          return "Last 6 months"
        case .lastYear:
          return "Last year"
        }
      }
      
      func apply(_ date: Date, now: () -> Date = {Date()}) -> Bool {
        let components: Set<Calendar.Component> = [.year, .month, .weekOfYear]
        let calendar = Calendar.autoupdatingCurrent
        let dateComponents = calendar.dateComponents(components, from: date)
        let nowComponents = calendar.dateComponents(components, from: date)
        let now = now()
        
        switch self {
        case .today:
          return calendar.isDateInToday(date)
        case .thisYear:
          return nowComponents.year == dateComponents.year
        case .thisWeek:
          return nowComponents.weekOfYear == dateComponents.weekOfYear
        case .thisMonth:
          return nowComponents.month == dateComponents.month
        case .last3Months:
          let difference: DateComponents = .init(month: -3)
          guard let date3monthsAgo = calendar.date(byAdding: difference, to: now) else {
            return false
          }
          return date > date3monthsAgo
        case .last6Months:
          let difference: DateComponents = .init(month: -6)
          guard let date6monthsAgo = calendar.date(byAdding: difference, to: now) else {
            return false
          }
          return date > date6monthsAgo
        case .lastYear:
          let difference: DateComponents = .init(year: -1)
          guard let dateYearAgo = calendar.date(byAdding: difference, to: now) else {
            return false
          }
          return date > dateYearAgo
        }
      }
    }
    public enum Filter: Hashable {
      case expenseType(MoneyRecord.RecordType)
      case dateRange(DateRange)
      
      public var stringValue: String {
        switch self {
        case .expenseType(let type):
          return type == .expense ? "Expense" : "Income"
        case .dateRange(let range):
          return range.stringValue
        }
      }
    }
    
    public var filteredTotal: Decimal  {
      let sum = filtered.reduce(Decimal.zero, { partialResult, record in
        if record.type == .expense {
          return partialResult - record.amount
        } else if record.type == .income {
          return partialResult + record.amount
        } else {
          fatalError("not handled record type")
        }
      })
      return sum
    }
    
    
    func filter(using filter: Filter) -> IdentifiedArrayOf<MoneyRecord> {
      records.filter { record in
        record.apply(filter: filter)
      }
    }
    
    public var filtered: IdentifiedArrayOf<MoneyRecord> {
      records
        .filter {
          $0.apply(filter: self.dateFilter)
        }
        .filter {
          $0.apply(filter: self.filter)
        }
    }
    
    public static let preview = Self.init(records: [
      .init(
        id: .init(),
        date: .init(),
        title: "sample expense",
        notes: "",
        type: .expense,
        amount: Decimal(123),
        currencyCode: "EUR",
        categories: []
      ),
      .init(
        id: .init(),
        date: .init(),
        title: "sample income",
        notes: "",
        type: .income,
        amount: Decimal(222),
        currencyCode: "EUR",
        categories: []
      ),
    ],
                                   baseCurrency: "USD")
  }
  
  public enum Action: Equatable {
    case changeFilter(State.Filter)
    case changeDateFilter(State.Filter)
  }
  
  public var body: some ReducerProtocol<State,Action> {
    Reduce { state, action in
      switch action {
      case .changeFilter(let filter):
        state.filter = filter
        return .none
      case .changeDateFilter(let filter):
        state.dateFilter = filter
        return .none
      }
    }
  }
}
