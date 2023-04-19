//
//  UserInfoTemplate.swift
//  
//
//  Created by Tomek Kuzma on 02/03/2023.
//

import Vapor
import SwiftHtml

struct UserInfoTemplate: TemplateRepresentable {
  
  var context: UserInfoContext
  
  @TagBuilder
  func render(_ req: Request) -> Tag {
    WebIndexTemplate(.init(title: "Hello", showTopMenu: true)) {
      Div {
        Section {
          H1(context.title)
          P(context.message)
        }
        .class("lead")
      }
      .id("user-info")
      .class("container")
    }
    .render(req)
  }
}
