//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 07/04/2023.
//

import Foundation
import Vapor
import SwiftHtml



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
        Div {
          Div {
            Table {
              Thead {
                Td("")
                  .class("headcol")
                
                for day in context.days {
                  Td(day.copy)
                }
              }
              Tbody {
                for hours in context.timesOfDay {
                  Tr {
                    Td(hours.copy)
                      .class("headcol")
                    for i in 0...6 {
                      Td("\(i)")
                    }
                  }
                  .class("weekly-calendar-row")
                }
              }
            }
            .class("offset")
          }
          .class("wrap")
        }
        .class("outer")
      }
      .class("calendar")
    }.render(req)
  }
  
//  @TagBuilder
//  func render(_ req: Request) -> Tag {
//    WebIndexTemplate(indexTemplate(req), style: context.calendarGridStyle) {
//      Div {
//        Section {
//          H1("Calendar")
//        }
//        .class("lead")
//        
//        
//        Ul {
//          
//          for event in context.events {
//            Li {
//              A(event.copy)
//                .style("display:block; width: 100%; height: 100%;")
//                .href(event.href)
//            }
//            .class(event.class)
//            .style(event.style)
//          }
//          
//          for day in context.days {
//            Li(day.copy)
//              .class(day.class)
//          }
//          
//          for time in context.timesOfDay {
//            Li(time.copy)
//              .class(time.class)
//          }
//          
//          Li()
//            .class("corner")
//          
//          for cell in context.cells {
//            Li {
//              A()
//                .style("display:block; width: 100%; height: 100%;")
//                .href(cell.href)
//            }
//            .class(cell.class)
//          }
//        }
//        .class("calendar weekly-byhour")
////        .style(context.calendarGridStyle)
//        
//      }
//      .id("calendar")
//    }
//    .render(req)
//  }
}
