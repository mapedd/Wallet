//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 01. 07..
//

import Vapor
import Fluent

extension TimeInterval {
  static func minutes(_ minutes: Int) -> TimeInterval {
    return TimeInterval(minutes) * 60
  }
}

public struct DateProvider {
  
  public init(
    calendar: Calendar = .autoupdatingCurrent,
    currentDate: @escaping () -> Date
  ) {
    self.calendar = calendar
    self.currentDate = currentDate
  }
  public var calendar: Calendar
  public var currentDate: () -> Date
  public var now: Date {
    currentDate()
  }
  
  public func deleteAccountConfirmationValid(date: Date) -> Bool {
    if date + .minutes(30) > now {
      return false
    } else {
      return true
    }
  }
  
  public func emailConfirmationValid(date: Date) -> Bool {
    if date + .minutes(30) > now {
      return false
    } else {
      return true
    }
  }
  public var tokenExpiryDate: Date {
    now.addingTimeInterval(60)
  }
  
  public var currentMonth: (month: Int, year: Int) {
    let comps = calendar.dateComponents([.month, .year], from: now)
    return (month: comps.month ?? 0, year: comps.year ?? 0)
  }
  
  public var currentWeeksBegining: (day: Int, month: Int, year: Int) {
    let weekBegining = calendar.startOfWeek(from: now)
    let comps = calendar.dateComponents([.month, .year, .day], from: weekBegining)
    return (
      day: comps.day ?? 0,
      month: comps.month ?? 0,
      year: comps.year ?? 0
    )
  }
}

struct UserTokenAuthenticator: AsyncBearerAuthenticator {
  
  var dateProvider: DateProvider
  init(
    dateProvider: DateProvider
  ) {
    self.dateProvider = dateProvider
  }
  
  func authenticate(bearer: BearerAuthorization, for req: Request) async throws {
    guard
      let token = try await UserTokenModel
        .query(on: req.db)
        .filter(\.$value == bearer.token)
        .first()
    else {
      return
    }
    
    // check if token not expired
    guard token.expiry > dateProvider.now else {
      return
    }
    
    guard
      let user = try await UserAccountModel
        .find(token.$user.id, on: req.db)
    else {
      return
    }
    req.auth.login(AuthenticatedUser(id: user.id!, email: user.email))
  }
}
