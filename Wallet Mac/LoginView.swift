//
//  LoginView.swift
//  Wallet
//
//  Created by Tomek Kuzma on 06/02/2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct LoginView: View {
  var screen = NSScreen.main?.visibleFrame
  var store: StoreOf<Login>
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("Wallet")
          .font(.largeTitle)
          .fontWeight(.heavy)
        
        
        TextField(
          text: viewStore.binding(\.$username),
          prompt: Text("Email"),
          label: {
            Label("Email", image: "pencil.line")
          }
        )
        .disableAutocorrection(true)
        
        SecureField("Password",
          text: viewStore.binding(\.$password),
          prompt: Text("Password")
        )
        Button("Log me in ") {
          viewStore.send(.logIn)
        }
        .disabled(!viewStore.buttonsEnabled)
        Spacer().frame(height: 100)
        Button("Register ") {
          viewStore.send(.register)
        }
        .disabled(!viewStore.buttonsEnabled)
        
        Spacer()
      }
      .ignoresSafeArea(.all, edges: .all)
      .frame(width: screen!.width / 3.8, height: screen!.height / 2.0)
    }
  }
}