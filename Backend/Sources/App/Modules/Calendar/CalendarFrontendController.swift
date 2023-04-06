//
//  CalendarFrontendController.swift
//  
//
//  Created by Tomek Kuzma on 06/04/2023.
//

import Foundation
import Vapor

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
  
  func monthlyCalendarView(req: Request) async throws -> Response {
    let template = CalendarTemplate(month(from: req))
    return req.templates.renderHtml(template)
  }
}
