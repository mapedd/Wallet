//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 06/04/2023.
//

import Foundation
import Vapor

enum Direction : String, Content {
  case next
  case prev
}


struct MonthCalendarRequest : Content {
  let month: Int
  let year: Int
  let direction:  Direction
  
  
  var uri: String {
    var comps = URLComponents()
    let items: [URLQueryItem] = [
      URLQueryItem(name: "month", value: "\(month)"),
      URLQueryItem(name: "year", value: "\(year)"),
      URLQueryItem(name: "direction", value: "\(direction.rawValue)")
    ]
    comps.queryItems = items
    return comps.url!.absoluteString
  }
  
  var next: Self {
    
    return .init(
      month: month == 12 ? 1 : month + 1,
      year: month == 12 ? year + 1 : year,
      direction: .next
    )
  }
  
  var prev: Self {
    
    return .init(
      month: month == 1 ? 12 : month - 1,
      year: month == 1 ? year - 1 : year,
      direction: .prev
    )
  }
}
