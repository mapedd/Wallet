//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 06/04/2023.
//

import Foundation

public struct MonthlyCalendarContext {
  
  public init(
    month: Int,
    year: Int,
    nextMonthURI: String,
    prevMonthURI: String
  ) {
    self.month = month
    self.year = year
    self.nextMonthURI = nextMonthURI
    self.prevMonthURI = prevMonthURI
    
    var customCalendar = Calendar(identifier: .gregorian)
    customCalendar.locale = Locale.autoupdatingCurrent
    customCalendar.firstWeekday = 2
    self.calendar = customCalendar
  }
  
  
  let month: Int
  let year: Int
  
  var calendar: Calendar
  
  var nextMonthURI: String
  var prevMonthURI: String
  
  var monthName: String {
    let dateComps = DateComponents(
      calendar: self.calendar,
      year: year,
      month: month
    )
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM YYYY"
    return formatter.string(from: calendar.date(from: dateComps)!)
  }
  
  var weekdays: [Weekday] {
    calendar.weekdaySymbols.shift(withDistance: 1).map{
      Weekday(name: $0)
    }
  }
  
  var firstDayOfTheMonth: Date {
    
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    
    // Get the first day of the month
    guard let firstDayOfMonth = calendar.date(from: dateComponents) else {
      return Date()
    }
    return firstDayOfMonth
  }
  
  var lastDayOfTheMonth: Date {
    
    var dateComponents = DateComponents()
    dateComponents.month = 1
    dateComponents.day = -1
    
    guard let lastDayOfTheMonth = calendar.date(byAdding: dateComponents, to: firstDayOfTheMonth) else {
      return Date()
    }
    
    return lastDayOfTheMonth
  }
  
  func numberOfWeeks(inMonth month: Int, year: Int) -> Int {
    
    
    /**
     1. sunday
     2. mon
     3. tue
     4. thu
     5. fri
     6. sat
     */
    
    // Get the number of days in the month
    guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfTheMonth)?.count else {
      return 0
    }
    
    // Get the number of weeks in the month by dividing the number of days by 7
    let numberOfWeeks = (numberOfDaysInMonth + calendar.component(.weekday, from: firstDayOfTheMonth) - 1) / 7
    
    return numberOfWeeks
  }
  
  var calendarBegining: Date {
    
    let weekDayOfFirstDay = calendar.component(.weekday, from: firstDayOfTheMonth)
    let toWeekBegining = DateComponents(calendar: calendar, day: -weekDayOfFirstDay + 2)
    let calendarBegining = calendar.date(byAdding: toWeekBegining, to: firstDayOfTheMonth)
    return calendarBegining!
  }
  
  var calendarEnd: Date {
    
    let weekDayOfLastDay = calendar.component(.weekday, from: lastDayOfTheMonth)
    let toWeekBegining = DateComponents(calendar: calendar, day: weekDayOfLastDay == 1 ? 0 : 8 - weekDayOfLastDay )
    let calendarEnd = calendar.date(byAdding: toWeekBegining, to: lastDayOfTheMonth)
    return calendarEnd!
  }
  
  var weekRows: [WeekRow] {
    let calendarBegining = calendarBegining
    let days = calendar.numberOfDaysBetween(
      calendarBegining,
      and: calendar.date(byAdding: .day, value: 1, to: calendarEnd)!
    )
    
    let range = Array(stride(from: 0, to: days, by: 1))
    let firstDayOfTheMonth = firstDayOfTheMonth
    let lastDayOfTheMonth = lastDayOfTheMonth
    
    
    let type: (_ date: Date) -> WeekItem.MonthType = { date in
      if date < firstDayOfTheMonth {
        return .previous
      }
      if date > lastDayOfTheMonth {
        return .next
      }
      return .current
    }
    
    let weekItems = range.map{
      let date = calendar.date(byAdding: .day, value: $0, to: calendarBegining)!
      let components = calendar.dateComponents([.day, .month, .year], from: date)
      let dateString = "\(components.day ?? 0)"
      
      return WeekItem(
        name: dateString,
        day: components.day ?? 0,
        month: components.month ?? 0,
        year: components.year ?? 0,
        monthType: type(date)
      )
    }
    
    return weekItems.chunk(into: 7).map { items in
      return WeekRow(weekItems: items)
    }
  }
  
  struct Weekday {
    let name: String
  }
  
  struct WeekRow {
    let weekItems: [WeekItem]
  }
  
  struct WeekItem {
    let name: String
    let day: Int
    let month: Int
    let year: Int
    let monthType: MonthType
    
    enum MonthType {
      case previous
      case current
      case next
    }
  }
}

extension Calendar {
  func endOfDay(for date: Date) -> Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return self.date(byAdding: components, to: self.startOfDay(for: date))!
  }
}

extension Array {
  func chunk(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

extension Calendar {
  func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
    let fromDate = startOfDay(for: from) // <1>
    let toDate = endOfDay(for: to) // <2>
    let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
    
    return numberOfDays.day!
  }
}

extension Array {
  
  /**
   Returns a new array with the first elements up to specified distance being shifted to the end of the collection. If the distance is negative, returns a new array with the last elements up to the specified absolute distance being shifted to the beginning of the collection.
   
   If the absolute distance exceeds the number of elements in the array, the elements are not shifted.
   */
  func shift(withDistance distance: Int = 1) -> Array<Element> {
    let offsetIndex = distance >= 0 ?
    self.index(startIndex, offsetBy: distance, limitedBy: endIndex) :
    self.index(endIndex, offsetBy: distance, limitedBy: startIndex)
    
    guard let index = offsetIndex else { return self }
    return Array(self[index ..< endIndex] + self[startIndex ..< index])
  }
  
  /**
   Shifts the first elements up to specified distance to the end of the array. If the distance is negative, shifts the last elements up to the specified absolute distance to the beginning of the array.
   
   If the absolute distance exceeds the number of elements in the array, the elements are not shifted.
   */
  mutating func shiftInPlace(withDistance distance: Int = 1) {
    self = shift(withDistance: distance)
  }
  
}
