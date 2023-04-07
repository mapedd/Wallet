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
        return calendar
    }()
  
  func startOfWeek(from date: Date) -> Date {
      self.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
  }
}

struct CalendarFrontendController {
  
  let dateProvider: DateProvider
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
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
  
  
  func dayData(from req: Request) async throws -> [WeekCalendarContext.DayData] {
    let now = dateProvider.now
    let weeksStart = Calendar.iso8601.startOfDay(for: now)
    
    return try await Array(stride(from: 0, to: 6, by: 1)).asyncMap { (offset :Int)  in
      let date = dateProvider.calendar.date(byAdding: .day, value: offset, to: weeksStart)!
      return WeekCalendarContext.DayData(
        date: date,
        status: .opened,
        openingHour: 8,
        closingHour: 20,
        options: [String:String](),
        events: try await events(at: date)
      )
    }
  }
  
  private func week(from req: Request) async throws -> WeekCalendarContext {
    return WeekCalendarContext(
      dateProvider: dateProvider,
      dayData: try await dayData(from: req)
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
