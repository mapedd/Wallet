//
//  BlogPostsTemplate.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import Vapor
import SwiftHtml

struct BlogPostsTemplate: TemplateRepresentable {
  var context: BlogPostsContext
  
  init(_ context: BlogPostsContext) {
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
        
        Div {
          for post in context.posts {
            Article {
              A {
                Img(src: post.image, alt: post.title)
                H2(post.title)
                P(post.excerpt)
              }
              .href("/\(post.slug)/")
            }
          }
        }
        .class("grid-221")
        
      }
      .id("blog")
    }
    .render(req)
  }
}
