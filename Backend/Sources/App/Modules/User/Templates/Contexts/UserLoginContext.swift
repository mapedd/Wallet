//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 31..
//

struct UserLoginContext {
  
  enum Mode {
    case signin
    case register
    case remindPassword
  }
  
  var icon: String {
    "🤙"
  }
  var title: String {
    switch mode {
    case .signin:
      return "Sign in"
    case .register:
      return "Register"
    case .remindPassword:
      return "Remind password"
    }
  }
  var message: String {
    switch mode {
    case .signin:
      return "Welcome"
    case .register:
      return "Create a new account"
    case .remindPassword:
      return ""
    }
  }
  
  let form: TemplateRepresentable
  let mode: Mode
  
  init(
    mode: Mode,
    form: TemplateRepresentable
  ) {
    self.mode = mode
    self.form = form
  }
  
  var showRegister: Bool {
    mode == .signin
  }
  
  var showForgotPassword: Bool {
    mode == .signin
  }
}

