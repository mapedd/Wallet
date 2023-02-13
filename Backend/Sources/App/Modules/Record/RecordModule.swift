//
//  RecordModule.swift
//
//
//  Created by Tomek Kuzma on 23/12/2022.
//

import Vapor
import Foundation

struct Message: Codable {
  var text: String
}

extension WebSocket: Hashable {
  public static func == (lhs: WebSocket, rhs: WebSocket) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}

struct RecordModule: ModuleInterface {
  
  var router: RecordRouter
  
  init(
    router: RecordRouter
  ) {
    self.router = router
  }
  
  func boot(_ app: Application) throws {
    app.migrations.add(RecordModelMigrations.v1())
//    app.webSocket("api/websocket") { req, ws in
//      ws.onText { ws, text in
//        app.logger.error("websocket received ws text \(text)")
//      }
//      ws.onPong { _ in
//        app.logger.error("websocket ponged")
//      }
//      app.logger.error("websocket connected")
//    }
//    app.webSocket("websocket") { request, ws in
//      ws.send("You have been connected to WebSockets")
//
//      let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
//        ws.send("another message \(Date())")
//      }
//      RunLoop.current.add(timer, forMode: .common)
//
//      ws.onText { ws, string in
//        ws.send(string.trimmingCharacters(in: .whitespacesAndNewlines).reversed())
//        ws.send("dupa")
//      }
//    }
//
//
//    var clientConnections = Set<WebSocket>()
//
//    app.webSocket("websocket") { req, client in
//      client.pingInterval = .seconds(10)
//
//      clientConnections.insert(client)
//
//      client.onClose.whenComplete { _ in
//        clientConnections.remove(client)
//      }
//
//      client.onText { ws, text in
//        do {
//          guard let data = text.data(using: .utf8) else {
//            return
//          }
//
//          let incomingMessage = try JSONDecoder().decode(Message.self, from: data)
//
//          let outgoingMessage = Message(text: incomingMessage.text.uppercased())
//
//          let json = try JSONEncoder().encode(outgoingMessage)
//
//          guard let jsonString = String(data: json, encoding: .utf8) else {
//            return
//          }
//
//          for connection in clientConnections {
//            connection.send(jsonString)
//          }
//        }
//        catch {
//          print(error)
//        }
//      }
//    }
    
    try self.router.boot(routes: app.routes)
  }
}

