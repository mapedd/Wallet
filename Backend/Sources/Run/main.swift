//
//  main.swift
//
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
//app.logger.logLevel = .debug
defer { app.shutdown() }
try configure(app, dateProvider: DateProvider(currentDate: { Date() }))

//let url = "ws://localhost:8080/api/websocket"
//let _ = WebSocket.connect(to: url, on: app.eventLoopGroup) { ws in
//  ws.onText { ws, text in
//    print(text)
//  }
//  
//  ws.sendPing()
//  
//  ws.onClose.whenComplete { result in
//      switch result {
//      case .success():
//        print("Closed")
//      case .failure(let error):
//        print("Failed to close connection \(error)")
//      }
//    }
//  
//  ws.send("Hello")
//}

try app.run()
