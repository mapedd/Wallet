//
//  LoginView.swift
//  Wallet
//
//  Created by Tomek Kuzma on 06/02/2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import WalletCore

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
        
        
        Group {
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
        }
        .frame(maxWidth: 250)

        Spacer()
          .frame(height: 50)

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
      .alert(self.store.scope(state: \.alert), dismiss: .alertCancelTapped)
      .padding()
//      .ignoresSafeArea(.all, edges: .all)
//      .frame(width: screen!.width / 3.8, height: screen!.height / 2.0)
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(
      store: .init(
        initialState: .init(alert: .userNotRegistered),
        reducer: Login()
      )
    )
  }
}
