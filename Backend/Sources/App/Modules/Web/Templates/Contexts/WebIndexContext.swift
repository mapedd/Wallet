//
//  WebIndexContext.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 29..
//

import Foundation

public struct WebIndexContext {
  public let title: String
  public let showTopMenu: Bool
  
  public init(
    title: String,
    showTopMenu: Bool
  ) {
    self.title = title
    self.showTopMenu = showTopMenu
  }
}
