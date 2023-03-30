//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 26/03/2023.
//

import Foundation
import Logging

//    let domain = "portfelmapedd.online"
let domain = "localhost:8080"
let productName = "Wallet"


enum Email {
  
  static func emailConfirmationLink(_ tokenId: String) -> String {
    let path = UserRouter.Route.confirmPassword.pathComponent
    let registerLink = "http://www.\(domain)/\(path)?token=\(tokenId)"
    return registerLink
  }
  
  static func deleteAccountLink(_ token: String) -> String {
    let path = UserRouter.Route.confirmDeleteAccount.pathComponent
    let registerLink = "http://www.\(domain)/\(path)?token=\(token)"
    return registerLink
  }
  
  static func resetPasswordLink(_ token: String) -> String {
    let path = UserRouter.Route.forgotPassword.pathComponent
    let registerLink = "http://www.\(domain)/\(path)?token=\(token)"
    return registerLink
  }
  
  static func deleteAccountRequest(
    tokenId: String,
    email: String,
    logger: Logger
  ) -> MailerSendEmail.Request {
    let link = deleteAccountLink(tokenId)
    
    logger.notice("user requested account deletion, generating confirm link: \(link)")
    
    let html = """
        <p>You've requested to delete your account. <a
        href="\(link)">
        Click here</a> to confirm that you want to delete, this cannot be undone.
        Link is valid for only 30 minutes</p>
        """
    
    return request(
      email: email,
      subject:  "Sad you to see you go :(. Please confirm account deletion",
      body: html
    )
  }
  
  static func emailConfirmationRequest(
    tokenId: String,
    email: String,
    logger: Logger
  ) -> MailerSendEmail.Request {
    
    let link = emailConfirmationLink(tokenId)
    
    logger.notice("registered user, generating confirm link: \(link)")
    
    let html = """
        <p>You've requested to register your account. <a
        href="\(link)">
        Click here</a> to confirm your email.
        It's valid for only 30 minutes</p>
        """
    
    let productName = "Wallet"
    
    return request(
      email: email,
      subject:  "Welcome to \(productName)! Please confirm your email",
      body: html
    )
  }
  
  static func request(
    email: String,
    subject: String,
    body: String
  ) -> MailerSendEmail.Request {
    
    let domainSender = "portfelmapedd.online"
    
    return .init(
      from: .init(
        email: "welcome@\(domainSender)",
        name: "Tomek"
      ),
      to: [
        .init(
          email: email,
          name: "New user"
        )
      ],
      subject:subject,
      text: "",
      html: body
    )
  }

}
