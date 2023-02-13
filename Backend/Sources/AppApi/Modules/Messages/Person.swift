import Foundation

public extension Websocket {
  public struct Person: Codable {
    public let name: String
    public let male: Bool
    public let age: Int
    public init(
      name: String,
      male: Bool,
      age: Int
    ) {
      self.name = name
      self.male = male
      self.age = age
    }
  }
}
