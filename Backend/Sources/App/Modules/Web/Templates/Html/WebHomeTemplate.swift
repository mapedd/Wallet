//
//  WebHomeTemplate.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import Vapor
import SwiftHtml

struct WebHomeTemplate: TemplateRepresentable {
  
  var context: WebHomeContext
  
  init(_ context: WebHomeContext) {
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
        
        for paragraph in context.paragraphs {
          P(paragraph)
        }
        
        WebLinkTemplate(context.link).render(req)
      }
      .id("home")
      .class("container")
    }
    .render(req)
  }
}
