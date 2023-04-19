//
//  CalendarFrontendController.swift
//  
//
//  Created by Tomek Kuzma on 06/04/2023.
//

import Foundation
import Vapor

extension Calendar {
  static let iso8601 = Calendar(identifier: .iso8601)
  static let iso8601UTC: Calendar = {
    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.firstWeekday = DayOfWeek.mon.rawValue
    return calendar
  }()
  
  func startOfWeek(from date: Date) -> Date {
    self.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
  }
}

struct CalendarFrontendController {
  
  let dateProvider: DateProvider
  
  var df = DateFormatter()
  
  
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
    df.dateStyle = .short
    df.timeStyle = .none
  }
  
  
  private func calendarRequest(from request: Request) -> MonthCalendarRequest {
    if let request = try? request.query.decode(MonthCalendarRequest.self) {
      return request
    } else {
      let currentDate = dateProvider.currentMonth
      
      return MonthCalendarRequest(
        month: currentDate.month,
        year: currentDate.year,
        direction: .next // this should not matter here
      )
      
    }
  }
  
  private func month(from req: Request) -> MonthlyCalendarContext {
    let request = calendarRequest(from: req)
    return .init(
      month: request.month,
      year: request.year,
      nextMonthURI: request.next.uri,
      prevMonthURI: request.prev.uri
    )
  }
  
  
  func events(at date: Date) async throws -> [WeekCalendarContext.DayData.Event] {
    [
      .init(
        title: "Washing",
        notes: "notes",
        id: UUID(),
        date: date,
        weekday: dateProvider.calendar.dayOfWeek(from: date),
        duration: 60 * 60
      )
    ]
  }
  //
//  var customCalendar = Calendar(identifier: .gregorian)
//  customCalendar.firstWeekday = 2
  
  func dayData(from request: WeekCalendarRequest) async throws -> [WeekCalendarContext.DayData] {
    
    let comps = DateComponents(
      year: request.year,
      month: request.month,
      day: request.day
    )
    let dateStart = dateProvider.calendar.date(from: comps)!
    let weeksStart = Calendar.iso8601.startOfWeek(from: dateStart)
    
    
    
    let weeksDays = Array(stride(from: 0, to: 7, by: 1)).map { offset in
      dateProvider.calendar.date(byAdding: .day, value: offset, to: weeksStart)!
    }
    
    return try await weeksDays.asyncMap { date  in
      return WeekCalendarContext.DayData(
        date: date,
        dayOfWeek: dateProvider.calendar.dayOfWeek(from: date),
        status: .opened,
        openingHour: 6,
        closingHour: 22,
        options: [String:String](),
        events: try await events(at: date)
      )
    }
  }
  
  private func weekRequest(from req: Request) -> WeekCalendarRequest {
    if let request = try? req.query.decode(WeekCalendarRequest.self) {
      return request
    } else {
      let currentDate = dateProvider.currentWeeksBegining
      
      return WeekCalendarRequest(
        day: currentDate.day,
        month: currentDate.month,
        year: currentDate.year,
        direction: .next // this should not matter here
      )
      
    }
  }
  
  private func week(from req: Request) async throws -> WeekCalendarContext {
    let weekRequest = weekRequest(from:req)
    
    let dayData = try await dayData(from: weekRequest)
    
    guard
      let weekStart = dayData.first?.date,
      let weekEnd = dayData.last?.date
    else {
      throw Abort(.failedDependency)
    }
    
    
    let weekName = "\(df.string(from: weekStart)) - \(df.string(from: weekEnd))"
    
    return WeekCalendarContext(
      dateProvider: dateProvider,
      dayData: dayData,
      headerCopy: weekName,
      nextWeekURI: weekRequest.next.uri,
      prevWeekURI: weekRequest.prev.uri
    )
  }
  
  func monthlyCalendarView(req: Request) async throws -> Response {
    let template = CalendarTemplate(month(from: req))
    return req.templates.renderHtml(template)
  }
  
  func weeklyCalendarView(req: Request) async throws -> Response {
    let template = try await WeeklyCalendarTemplate(week(from: req))
    return req.templates.renderHtml(template)
  }
}
