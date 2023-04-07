//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 07/04/2023.
//

import Foundation
import Vapor
import SwiftHtml
import UUIDShortener

enum DayOfWeek: Int{
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

struct WeekCalendarContext {
  
  let dayData: [DayData]
  let dateProvider: DateProvider
  
  init(
    dateProvider: DateProvider,
    dayData: [DayData] // 7 of them, sorted from earliest to latest
  ) {
    self.dayData = dayData
    self.dateProvider = dateProvider
  }
  
  struct DayData {
    struct Event: Identifiable {
      let title: String
      let notes: String
      let id: UUID
      let date: Date
      let weekday: DayOfWeek
      let duration: TimeInterval // seconds
      
      var gridColumn: String {
        "mon"
      }
      
      var gridRow: String {
        "h08   /  h11"
      }
//      grid-column:   mon;   grid-row:  h08   /  h11;
    }
    
    // is venue opened given day
    enum Status {
      case closed
      case opened
    }
    
    var date: Date
    var status: Status
    var openingHour: Int // 0 - 24
    var closingHour: Int // openingHour - 24
    var options: [String: String]
    var events: [Event]
  }
  
  //  let nextWeekURI: String
  //  let prevWeekURI: String
  
//  enum DayOfWeek: Int{
//    case sun = 1
//    case mon = 2
//    case tue = 3
//    case wed = 4
//    case thu = 5
//    case fri = 6
//    case sat = 7
//    
//    var day: Day {
//      switch self {
//        
//      case .mon: return .init(copy: "Mon", class: "day mon")
//      case .tue: return .init(copy: "Tue", class: "day tue")
//      case .wed: return .init(copy: "Wed", class: "day wed")
//      case .thu: return .init(copy: "Thu", class: "day thu")
//      case .fri: return .init(copy: "Fri", class: "day fri")
//      case .sat: return .init(copy: "Sat", class: "day sat")
//      case .sun: return .init(copy: "Sun", class: "day sun")
//      }
//    }
//  }
  
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
  
//  let days: [Day] = [
//    .init(copy: "Mon", class: "day mon"),
//    .init(copy: "Tue", class: "day tue"),
//    .init(copy: "Wed", class: "day wed"),
//    .init(copy: "Thu", class: "day thu"),
//    .init(copy: "Fri", class: "day fri"),
//    .init(copy: "Sat", class: "day sat"),
//    .init(copy: "Sun", class: "day sun")
//  ]
  
  let cells: [Cell] = Array(stride(from: 0, to: 7 * 24, by: 1)).map { index in
      .init(
        href: "weekly/\(index)",
        class: "hour-cell"
      )
  }
  
  struct Cell {
    let href: String
    let `class`: String
  }
  
  
  
  let timesOfDay: [TimeOfDay] = [
    .init(copy: "12:00 am", class: "time h00"),
    .init(copy: "1:00 am", class: "time h01"),
    .init(copy: "2:00 am", class: "time h02"),
    .init(copy: "3:00 am", class: "time h03"),
    .init(copy: "4:00 am", class: "time h04"),
    .init(copy: "5:00 am", class: "time h05"),
    .init(copy: "6:00 am", class: "time h06"),
    .init(copy: "7:00 am", class: "time h07"),
    .init(copy: "8:00 am", class: "time h08"),
    .init(copy: "9:00 am", class: "time h09"),
    .init(copy: "10:00 am", class: "time h10"),
    .init(copy: "11:00 am", class: "time h11"),
    .init(copy: "12:00 pm", class: "time h12"),
    .init(copy: "1:00 pm", class: "time h13"),
    .init(copy: "2:00 pm", class: "time h14"),
    .init(copy: "3:00 pm", class: "time h15"),
    .init(copy: "4:00 pm", class: "time h16"),
    .init(copy: "5:00 pm", class: "time h17"),
    .init(copy: "6:00 pm", class: "time h18"),
    .init(copy: "7:00 pm", class: "time h19"),
    .init(copy: "8:00 pm", class: "time h20"),
    .init(copy: "9:00 pm", class: "time h21"),
    .init(copy: "10:00 pm", class: "time h22"),
    .init(copy: "11:00 pm", class: "time h23")
  ]
  
  var events: [Event] {
    self.dayData.map(\.events).flatMap { $0 }.map {
      .init(
        copy: $0.title,
        class: "event work",
        style: "grid-column: \($0.gridColumn); grid-row:  \($0.gridRow);",
        href: "event/\($0.id.urlFriendly)"
        )
    }
  }
  
//  let events: [Event] = [
//
//    .init(
//      copy: "Finish this calendar",
//      class: "event work",
//      style: "grid-column:   mon;   grid-row:  h08   /  h11;  ",
//      href: "event/4"
//    ),
//    .init(
//      copy: "Master the grid!",
//      class: "event work",
//      style: "grid-column:   wed;   grid-row:  h10   /  h19;  ",
//      href: "event/3"
//    ),
//    .init(
//      copy: "After work drinks",
//      class: "event personal",
//      style: "grid-column:   fri;   grid-row:  h16   /  h23;  ",
//      href: "event/2"
//    ),
//    .init(
//      copy: "Soccer game",
//      class: "event personal",
//      style: "grid-column:   tue;   grid-row:  h18   /  h20;  ",
//      href: "event/1"
//    )
//  ]
  
  struct Event {
    let copy: String
    let `class`: String
    let style: String
    let href: String
  }
  
  
  struct TimeOfDay {
    let copy: String
    let `class`: String
  }
}


struct WeeklyCalendarTemplate: TemplateRepresentable {
  var context: WeekCalendarContext
  
  init(_ context: WeekCalendarContext) {
    self.context = context
  }
  
  func indexTemplate(_ req:Request) -> WebIndexContext {
    .init(
      title: "title",
      showTopMenu: !req.application.environment.isComingSoon
    )
  }
  
  
  @TagBuilder
  func render(_ req: Request) -> Tag {
    WebIndexTemplate(indexTemplate(req)) {
      Div {
        Section {
          H1("Calendar")
        }
        .class("lead")
        
        
        Ul {
          
          for event in context.events {
            Li {
              A(event.copy)
                .style("display:block; width: 100%; height: 100%;")
                .href(event.href)
            }
            .class(event.class)
            .style(event.style)
          }
          
          for day in context.days {
            Li(day.copy)
              .class(day.class)
          }
          
          for time in context.timesOfDay {
            Li(time.copy)
              .class(time.class)
          }
          
          Li()
            .class("corner")
          
          for cell in context.cells {
            Li {
              A()
                .style("display:block; width: 100%; height: 100%;")
                .href(cell.href)
            }
            .class(cell.class)
          }
        }
        .class("calendar weekly-byhour")
        
      }
      .id("calendar")
    }
    .render(req)
  }
}
