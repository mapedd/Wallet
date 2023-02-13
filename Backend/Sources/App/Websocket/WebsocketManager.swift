import Vapor
import Fluent

class WebsocketManager {
  var clients: WebsocketClients
  var app: Application
  
  init(app: Application) {
    let eventLoop = app.eventLoopGroup.next()
    clients = WebsocketClients(eventLoop: eventLoop)
    self.app = app
  }
  
  func connect(_ ws: WebSocket) {
    ws.onBinary { [unowned self] ws, buffer in
      app.logger.info("received binary")
      guard let msg = buffer.decodeWebsocketMessage(Websocket.Connect.self) else {
        app.logger.info("failed to decode binary")
       return
      }
      let client = WebsocketClient(
        id: msg.client,
        socket: ws
      )
      await self.clients.add(client)
      
      app.logger.info("Added client app: \(msg.client)")
      
      do {
        try await notify()
      } catch {
        app.logger.info("error notifiing \(error)")
      }
    }
    
    ws.onText { ws, _ in
      ws.send("pong")
    }
  }
  
  func notify() async throws {
    let connectedClients = await clients.active.compactMap { $0 as WebsocketClient }
    guard !connectedClients.isEmpty else {
      return
    }
    
    try await connectedClients.asyncForEach { client in
    
      guard
        let user = try await UserAccountModel
          .query(on: app.db)
          .filter(\.$id == client.id)
          .first()
      else {
        return
      }
      
      let records =  try await user
        .$records
        .query(on: app.db)
        .filter(\.$deleted == nil)
        .all()
      
      let person = Websocket.Person(name: user.email, male: true, age: records.count)
      let msg = WebsocketMessage<Websocket.Person>(client: client.id, data: person)
      let data = try! JSONEncoder().encode(msg)
      
      try await client.socket.send([UInt8](data))
    }
  }
}

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
