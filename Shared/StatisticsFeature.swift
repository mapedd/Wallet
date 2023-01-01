//
//  StatisticsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

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

struct Statistics: ReducerProtocol {
  
  struct State: Equatable {
    
    var records: IdentifiedArrayOf<Record.State> = []
    var filter: Filter = .expenseType(.expense)
    var dateFilter: Filter = .dateRange(.thisWeek)
    var showDateFilter = false
    
    var formattedFilteredTotal: String {
      return filteredTotal.formattedDecimalValue
    }
    
    enum DateRange: Identifiable, Hashable, CaseIterable {
      var id: String {
        self.stringValue
      }
      
      case today
      case thisYear
      case thisWeek
      case thisMonth
      
      
      case last3Months
      case last6Months
      case lastYear
      
      var stringValue: String {
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
    enum Filter: Hashable {
      case expenseType(MoneyRecord.RecordType)
      case dateRange(DateRange)
      
      var stringValue: String {
        switch self {
        case .expenseType(let type):
          return type == .expense ? "Expense" : "Income"
        case .dateRange(let range):
          return range.stringValue
        }
      }
    }
    
    var filteredTotal: Decimal  {
      let sum = filtered.reduce(Decimal.zero, { partialResult, recordState in
        if recordState.record.type == .expense {
          return partialResult - recordState.record.amount
        } else if recordState.record.type == .income {
          return partialResult + recordState.record.amount
        } else {
          fatalError("not handled record type")
        }
      })
      return sum
    }
    
    
    func filter(using filter: Filter) -> IdentifiedArrayOf<Record.State> {
      records.filter { recordState in
        recordState.record.apply(filter: filter)
      }
    }
    
    var filtered: IdentifiedArrayOf<Record.State> {
      records
        .filter {
          $0.record.apply(filter: self.dateFilter)
        }
        .filter {
          $0.record.apply(filter: self.filter)
        }
    }
    
    static let preview = Self.init(records: [
      Record.State(
        record: .init(
          id: .init(),
          date: .init(),
          title: "sample expense",
          type: .expense,
          amount: Decimal(123),
          currency: .eur
        )
      ),
      Record.State(
        record: .init(
          id: .init(),
          date: .init(),
          title: "sample income",
          type: .income,
          amount: Decimal(222),
          currency: .eur
        )
      ),
    ])
  }
  
  enum Action {
    case changeFilter(State.Filter)
    case recordAction(id: Record.State.ID, action: Record.Action)
    case changeDateFilter(State.Filter)
  }
  
  var body: some ReducerProtocol<State,Action> {
    Reduce { state, action in
      switch action {
      case .changeFilter(let filter):
        state.filter = filter
        return .none
      case .recordAction:
        return .none
      case .changeDateFilter(let filter):
        state.dateFilter = filter
        return .none
      }
    }
    .forEach(\.records, action: /Action.recordAction(id:action:)) {
      Record()
    }
    
  }
}
//let statisticsCoreReducer = Reducer
//<
//  StatisticsState,
//  StatisticsAction,
//  StatisticsEnvironment
//> { state, action, _ in
//  switch action {
//  case .changeFilter(let filter):
//    state.filter = filter
//    return .none
//  case .recordAction(id: let id, action: let action):
//    return .none
//  case .changeDateFilter(let filter):
//    state.dateFilter = filter
//    return .none
//  }
//}
//
//let statisticsReducer = Reducer
//<
//  StatisticsState,
//  StatisticsAction,
//  StatisticsEnvironment
//>.combine(
//combinedRecordReducer.forEach(
//  state: \.records,
//  action: /StatisticsAction.recordAction(id:action:),
//  environment: { _ in RecordEnvironment() }
//),
//statisticsCoreReducer
//)
