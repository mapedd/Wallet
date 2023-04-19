//
//  CalendarRouter.swift
//  
//
//  Created by Tomek Kuzma on 06/04/2023.
//

import Foundation
import Vapor

struct CalendarRouter: RouteCollection {
  
  let dateProvider: DateProvider
  let frontendController: CalendarFrontendController
  
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
    
    self.frontendController = CalendarFrontendController(dateProvider:dateProvider)
  }
  
  func boot(routes: RoutesBuilder) throws {
    routes.get("calendar", use: frontendController.monthlyCalendarView)
    routes.get("week", use: frontendController.weeklyCalendarView)
  }
}
