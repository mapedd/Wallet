//
//  WeekCalendarRequest.swift
//  
//
//  Created by Tomek Kuzma on 12/04/2023.
//

import Foundation
import Vapor

struct WeekCalendarRequest : Content {
  
  init(
    day: Int,
    month: Int,
    year: Int,
    direction: Direction
  ) {
    self.day = day
    self.month = month
    self.year = year
    self.direction = direction
  }
  
  // start of the calendar from the left
  let day: Int
  let month: Int
  let year: Int
  
  let direction:  Direction
  
  
  var uri: String {
    var comps = URLComponents()
    let items: [URLQueryItem] = [
      URLQueryItem(name: "day", value: "\(day)"),
      URLQueryItem(name: "month", value: "\(month)"),
      URLQueryItem(name: "year", value: "\(year)"),
      URLQueryItem(name: "direction", value: "\(direction.rawValue)")
    ]
    comps.queryItems = items
    return comps.url!.absoluteString
  }
  
  var calendar: Calendar {
    Calendar.autoupdatingCurrent
  }
  
  private func comps(in direction: Direction) -> (day: Int, month: Int, year: Int) {
    
    var comps = DateComponents(
      calendar: calendar,
      year: year,
      month: month,
      day: day
    )
    
    let date = calendar.date(from: comps)
    
    let value = direction == .next ? 1 : -1
    
    let nextWeek = calendar.date(byAdding: .weekOfMonth, value: value, to: date!)
    
    let nextWeekStartComps = calendar.dateComponents([.day, .month, .year], from: nextWeek!)
    
    return (
      day: nextWeekStartComps.day!,
      month: nextWeekStartComps.month!,
      year: nextWeekStartComps.year!
    )
  }
  
  var next: Self {
    
    let comps = comps(in: .next)
    
    return .init(
      day: comps.day,
      month: comps.month,
      year: comps.year,
      direction: .next
    )
  }
  
  var prev: Self {
    
    let comps = comps(in: .prev)
    
    return .init(
      day: comps.day,
      month: comps.month,
      year: comps.year,
      direction: .next
    )
  }
}
