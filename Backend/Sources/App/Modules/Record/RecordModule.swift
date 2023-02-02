//
//  RecordModule.swift
//
//
//  Created by Tomek Kuzma on 23/12/2022.
//

import Vapor

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
//        app.logger.error("received ws text \(text)")
//      }
//      ws.onPong { _ in
//        app.logger.error("ponged")
//      }
//    }
//    app.webSocket("") { request, ws in
//      ws.send("You have been connected to WebSockets")
//      
//      ws.onText { ws, string in
//        ws.send(string.trimmingCharacters(in: .whitespacesAndNewlines).reversed())
//      }
//    }
    try self.router.boot(routes: app.routes)
  }
}

