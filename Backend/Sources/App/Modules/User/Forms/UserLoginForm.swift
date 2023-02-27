//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 01. 01..
//

import Vapor

final class UserLoginForm: AbstractForm {
  
  var mode: UserLoginContext.Mode = .signin
  
  public convenience init(mode: UserLoginContext.Mode) {
    
    self.init(
      action: .init(
        method: .post,
        url: mode.urlAction
      ),
      submit: mode.titleAction
    )
    self.mode = mode
    self.fields = createFields()
  }
  
  @ArrayBuilder<FormComponent>
  func createFields() -> [FormComponent] {
    InputField("email")
      .config {
        $0.output.context.label.required = true
        $0.output.context.type = .email
      }
      .validators {
        FormFieldValidator.required($1)
        FormFieldValidator.email($1)
      }
    if mode != .remindPassword {
      InputField("password")
        .config {
          $0.output.context.label.required = true
          $0.output.context.type = .password
        }
        .validators {
          FormFieldValidator.required($1)
        }
    }
  }
}
