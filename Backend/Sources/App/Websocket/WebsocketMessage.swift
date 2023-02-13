import Vapor
import AppApi

extension ByteBuffer {
  func decodeWebsocketMessage<T: Codable>(_: T.Type) -> WebsocketMessage<T>? {
    return try? JSONDecoder().decode(WebsocketMessage<T>.self, from: self)
  }
}
