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
  
  init(context: UserLoginContext) {
    self.context = context
  }
  
  @TagBuilder
  func render(_ req: Request) -> Tag {
    WebIndexTemplate(.init(title: context.title)) {
      Div {
        Section {
          P(context.icon)
          H1(context.title)
          P(context.message)
        }
        .class("lead")
        
        context.form.render(req)
        
        if context.showForgotPassword {
          Section {
            A("Forgot your password?")
              .href(UserRouter.Route.forgotPassword.href)
            
          }
        }
        
        if context.showRegister {
          Section {
            A("Register")
              .href(UserRouter.Route.register.href)
          }
        }
        
      }
      .id("user-login")
      .class("container")
    }
    .render(req)
  }
}
