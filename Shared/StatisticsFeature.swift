//
//  StatisticsFeature.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 18/09/2022.
//

import Foundation
import ComposableArchitecture

extension MoneyRecord {
  func apply(filter: StatisticsState.Filter) -> Bool {
    switch filter {
    case .expenseType(let type):
      return type == self.type
    case .dateRange(let dateRange):
      return dateRange.apply(self.date)
    }
  }
}

struct StatisticsState: Equatable {

  var records: IdentifiedArrayOf<RecordState> = []
  var filter: Filter = .expenseType(.expense)
  var dateFilter: Filter = .dateRange(.thisWeek)

  enum DateRange {
    case today
    case thisYear
    case thisWeek
    case thisMonth


    case last3Months
    case last6Months
    case lastYear

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
  

  func filter(using filter: Filter) -> IdentifiedArrayOf<RecordState> {
    records.filter { recordState in
      recordState.record.apply(filter: filter)
    }
  }

  var filtered: IdentifiedArrayOf<RecordState> {
    records
      .filter {
        $0.record.apply(filter: self.dateFilter)
      }
      .filter {
        $0.record.apply(filter: self.filter)
      }
  }

  static let preview = Self.init(records: [
    RecordState(
      record: .init(
        id: .init(),
        date: .init(),
        title: "sample expense",
        type: .expense,
        amount: Decimal(123),
        currency: .eur
      )
    ),
    RecordState(
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

enum StatisticsAction {
  case datePickerTapped
  case changeFilter(StatisticsState.Filter)
  case recordAction(id: RecordState.ID, action: RecordAction)
}

struct StatisticsEnvironment {

}

let statisticsReducer = Reducer
<
  StatisticsState,
  StatisticsAction,
  StatisticsEnvironment
> { state, action, _ in
  switch action {

  case .datePickerTapped:
    return .none
  case .changeFilter(let filter):
    state.filter = filter
    return .none
  case .recordAction(id: let id, action: let action):
    return .none
  }
}
