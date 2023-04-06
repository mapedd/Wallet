//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 06/04/2023.
//

import Foundation
import Vapor
import SwiftHtml


struct CalendarTemplate: TemplateRepresentable {
  var context: MonthlyCalendarContext
  
  init(_ context: MonthlyCalendarContext) {
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
        
        Div {
          Div {
            H3(context.monthName)
              .id("monthAndYear")
            
            Div {
              A("<")
                .href("/calendar\(context.prevMonthURI)")
                .id("previous")
              
              A(">")
                .href("/calendar\(context.nextMonthURI)")
                .id("next")
            }
            .class("button-container-calendar")
            
            Table {
              Thead {
                for day in context.weekdays {
                  Th(day.name)
                }
              }
              .id("thead-month")
              
              Tbody {
                for weekRow in context.weekRows {
                  Tr {
                    for day in weekRow.weekItems {
                      Td(day.name)
                        .style("text-align: center")
                        .class(day.monthType != .current ? "other-month" : "current-month")
                    }
                  }
                }
              }
              .id("calendar-body")
            }
            .id("calendar")
            .class("table-calendar")
            
          }
          .class("container-calendar")
        }
        .class("wrapper")
        
      }
      .id("calendar")
    }
    .render(req)
  }
}
