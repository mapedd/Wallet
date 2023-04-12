//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 07/04/2023.
//

import Foundation
import UUIDShortener
import Vapor

enum DayOfWeek: Int, CaseIterable {
  case sun = 1
  case mon = 2
  case tue = 3
  case wed = 4
  case thu = 5
  case fri = 6
  case sat = 7
}

extension DayOfWeek {
  var day: WeekCalendarContext.Day {
    switch self {
      
    case .mon: return .init(copy: "Mon", class: "day mon")
    case .tue: return .init(copy: "Tue", class: "day tue")
    case .wed: return .init(copy: "Wed", class: "day wed")
    case .thu: return .init(copy: "Thu", class: "day thu")
    case .fri: return .init(copy: "Fri", class: "day fri")
    case .sat: return .init(copy: "Sat", class: "day sat")
    case .sun: return .init(copy: "Sun", class: "day sun")
    }
  }
}

extension Calendar {
  func dayOfWeek(from date: Date) -> DayOfWeek {
    let weekday = component(.weekday, from: date)
    return DayOfWeek(rawValue: weekday) ?? .mon
  }
}

extension UUID {
  var urlFriendly: String {
    let shortened: String? = try? self.shortened(using: Alphabet.base62)
    return shortened ?? ""
  }
}

extension DayOfWeek {
  var gridColumn: String {
    switch self {
    case .sun: return "sun"
    case .mon: return "mon"
    case .tue: return "tue"
    case .wed: return "wed"
    case .thu: return "thu"
    case .fri: return "fri"
    case .sat: return "sat"
    }
  }
}

struct WeekCalendarContext {
  
  let dayData: [DayData]
  let dateProvider: DateProvider
  let headerCopy: String
  let nextWeekURI: String
  let prevWeekURI: String
  
  private func date(for day: DayOfWeek) throws -> Date {
    let dayData = dayData.first { $0.dayOfWeek == day }
    guard
      let dayData
    else {
      throw Abort(.internalServerError)
    }
    
    return dayData.date
  }
  
  private func comps(day: DayOfWeek, time: Time) -> DateComponents {
    guard let date = try? date(for: day) else {
      return DateComponents()
    }
    
    let cal = Calendar.current
    var comps = cal.dateComponents([.year, .month, .day], from: date)
    comps.hour = time.hour
    comps.minute = time.minute
    comps.second = time.second
    
    return comps
  }
  
  func href(
    for day: DayOfWeek,
    timeOfDay: TimeOfDay
  ) -> String {
    let dateComps = comps(day: day, time: timeOfDay.time)
    var comps = URLComponents()
    comps.path = "time"
    let items: [URLQueryItem] = [
      URLQueryItem(name: "year", value: "\(dateComps.year ?? 0)"),
      URLQueryItem(name: "month", value: "\(dateComps.month ?? 0)"),
      URLQueryItem(name: "day", value: "\(dateComps.day ?? 0)"),
      URLQueryItem(name: "hour", value: "\(dateComps.hour ?? 0)"),
      URLQueryItem(name: "minute", value: "\(dateComps.minute ?? 0)"),
      URLQueryItem(name: "second", value: "\(dateComps.second ?? 0)")
    ]
    comps.queryItems = items
    return comps.url!.absoluteString
  }
  
  init(
    dateProvider: DateProvider,
    dayData: [DayData], // 7 of them, sorted from earliest to latest,
    headerCopy: String,
    nextWeekURI: String,
    prevWeekURI: String
  ) {
    self.dayData = dayData
    self.dateProvider = dateProvider
    self.nextWeekURI = nextWeekURI
    self.prevWeekURI = prevWeekURI
    self.headerCopy = headerCopy
  }
  
  struct DayData {
    struct Event: Identifiable {
      let title: String
      let notes: String
      let id: UUID
      let date: Date
      let weekday: DayOfWeek
      let duration: TimeInterval // seconds
      
    }
    
    // is venue opened given day
    enum Status {
      case closed
      case opened
    }
    
    var date: Date
    var dayOfWeek: DayOfWeek
    var status: Status
    var openingHour: Int // 0 - 24
    var closingHour: Int // openingHour - 24
    var options: [String: String]
    var events: [Event]
  }
  
  
  struct Day {
    let copy: String
    let `class`: String
  }
  
  var days: [Day] {
    dayData
      .map(\.date)
      .map{ dateProvider.calendar.dayOfWeek(from: $0)}
      .map(\.day)
  }
  
  var cells: [Cell] {
    let hours = hoursInWorkingDay.count
    let days = dayData.count
    return Array(stride(from: 0, to: days * hours, by: 1)).map { index in
        .init(
          href: "weekly/\(index)",
          class: "hour-cell"
        )
    }
  }
  
  struct Cell {
    let href: String
    let `class`: String
  }
  
  var hoursInWorkingDay: [Int] {
    guard
      let minStart = dayData.map(\.openingHour).min(),
      let maxStart = dayData.map(\.closingHour).max()
    else {
      return []
    }
    let seed: [Int] = Array(stride(from: minStart, to: maxStart, by: 1))
    return seed
  }
  
  var timesOfDay: [TimeOfDay] {
    
    let df = DateFormatter()
    df.timeStyle = .short
    df.dateStyle = .none
    
    let cal = dateProvider.calendar
    
    return hoursInWorkingDay.map { i in
      var comps  = cal.dateComponents([.year, .month, .day], from: dateProvider.now)
      comps.hour = i
      comps.minute = 0
      comps.second = 0
      let date = cal.date(from: comps)
      
      return .init(
        copy: df.string(from: date!),
        time: Time(hour: i, minute: 0, second: 0),
        class: "time h\(String(format: "%02d", i))"
      )
    }
  }
  
  
  var events: [Event] {
    self.dayData.map(\.events).flatMap { $0 }.map {
      .init(
        copy: $0.title,
        href: "event/\($0.id.urlFriendly)"
      )
    }
  }
  
  struct Event {
    let copy: String
    let href: String
  }
  
  struct TimeOfDay {
    let copy: String
    let time: Time
    let `class`: String
  }
  
  struct Time {
    let hour: Int
    let minute: Int
    let second: Int
  }
  
  var hours: String {
    hoursInWorkingDay.map {
      "[h\(String(format: "%02d", $0))]  1fr"
    }.joined(separator: "\n")
  }
}
