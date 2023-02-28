//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

import Vapor
import SwiftHtml

struct UserLoginTemplate: TemplateRepresentable {
  
  var context: UserLoginContext
  
  init(_ context: UserLoginContext) {
    self.context = context
  }
  
  func indexTemplate(_ req:Request) -> WebIndexContext {
    .init(
      title: context.title,
      showTopMenu: !req.application.environment.isComingSoon
    )
  }
  
  @TagBuilder
  func render(_ req: Request) -> Tag {
    WebIndexTemplate(indexTemplate(req)) {
      Div {
        Section {
          P(context.icon)
          H1(context.title)
          P(context.message)
        }
        .class("lead")
        
        context.form.render(req)
      }
      .id("user-login")
      .class("container")
    }
    .render(req)
  }
}
