import Foundation

public extension Websocket {
  struct RecordUpdate: Codable {
    public let title: String
    public let id: UUID
    public init(
      title: String,
      id: UUID
    ) {
      self.title = title
      self.id = id
    }
  }
}
