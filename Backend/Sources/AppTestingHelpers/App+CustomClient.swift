//
//  App+CustomClient.swift
//  
//
//  Created by Tomek Kuzma on 13/03/2023.
//

import Vapor
import XCTest
import XCTVapor
import SwiftSoup

extension Application {
  
  public func prepareCustomClient() {
    
    let client = CustomClient()
    client.responseGenerator = { req in
      return ClientResponse(
        status: .ok,
        headers: HTTPHeaders(),
        body: nil,
        byteBufferAllocator: ByteBufferAllocator()
      )
    }
    
    let provider = Application.Clients.Provider.custom
    storage[Application.CustomClientKey.self] = client
    clients.use(provider)
  }
  
  struct HTML: Codable {
    var html: String
  }
  
  // this will check sent external requests , get the message
  // extract the deeplink and call that in
  public func confirm(email address: String) async throws {
    let req = try XCTUnwrap(customClient.requestsReceived.first)
    customClient.requestsReceived.removeFirst()
    
    var sendEmail: HTML?
    do {
      sendEmail = try req.content.decode(HTML.self)
    } catch {
      XCTFail(error.localizedDescription)
    }
    
    let sendEmailUnwrapped = try XCTUnwrap(sendEmail)
    
    let html = sendEmailUnwrapped.html
    let doc: Document = try SwiftSoup.parse(html)
    let link: Element = try doc.select("a").first()!
    let linkHref: String = try link.attr("href")
  
    
    let components = try XCTUnwrap(URLComponents(string: linkHref))
    var path = components.path + "?"
    for component in components.queryItems! {
      path.append("\(component.name)=\(component.value!)")
    }
    
    try self.test(.GET, path, afterResponse: { _ in })
  }
}
