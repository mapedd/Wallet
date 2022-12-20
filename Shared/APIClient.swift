//
//  APIClient.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import Foundation
import AppApi


struct APIClient {
  var signIn: (User.Account.Login) async throws -> User.Token.Detail?
  var signOut: (User.Token.Detail) async throws -> Void 
  
  static var live: APIClient {
    let url = URL(string: "http://localhost:8080/api/")
    let session = URLSession.shared
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    return APIClient(
      signIn: { login in
        var request = URLRequest(url: URL(string: "sign-in/", relativeTo: url)!)
        request.httpBody = try encoder.encode(login)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
          let (data, _) = try await session.data(for:request)
          return try decoder.decode(User.Token.Detail.self, from: data)
        }
        catch {
          debugPrint("error sign in \(error)")
          return nil
        }
        
      }
    )
  }
  static let mock = APIClient(
    signIn: { _ in
      User.Token.Detail(id: .init(), value: "asd", user: .init(id: .init(), email: "asd"))
    }
  )
}
