import Foundation

public enum Websocket {}

public extension Websocket {
  struct Connect: Codable {
    public var id: UUID
    public var connect: Bool
    
    public init(
      id: UUID,
      connect: Bool
    ) {
      self.id = id
      self.connect = connect
    }
  }
}
