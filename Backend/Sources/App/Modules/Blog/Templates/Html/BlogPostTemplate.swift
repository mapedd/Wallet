//
//  BlogPostTemplate.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import Vapor
import SwiftHtml

struct BlogPostTemplate: TemplateRepresentable {
  
  var context: BlogPostContext
  
  init(_ context: BlogPostContext) {
    self.context = context
  }
  
  func indexTemplate(_ req:Request) -> WebIndexContext {
    .init(
      title: context.post.title,
      showTopMenu: !req.application.environment.isComingSoon
    )
  }
  
  var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
  }()
  
  @TagBuilder
  func render(_ req: Request) -> Tag {
    WebIndexTemplate(indexTemplate(req)) {
      Div {
        Section {
          P(dateFormatter.string(from: context.post.date))
          H1(context.post.title)
          P(context.post.excerpt)
        }
        .class(["lead", "container"])
        
        Img(src: context.post.image, alt: context.post.title)
        
        Article {
          Text(context.post.content)
        }
        .class("container")
      }
      .id("post")
    }
    .render(req)
  }
}
