//
//  Login.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import SwiftUI
import ComposableArchitecture


struct  LoginView: View {
  var store: StoreOf<Login>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView {
        VStack {
          Spacer()
          Text("Wallet")
          TextField("Email",
            text: viewStore.binding(\.$username)
          )
          .autocapitalization(.none)
          .disableAutocorrection(true)
          .keyboardType(.emailAddress)
          
          SecureField("Password",
            text: viewStore.binding(\.$password)
          )
          Button("Log me in ") {
            viewStore.send(.logIn)
          }
          Spacer().frame(height: 100)
          Button("Register ") {
            viewStore.send(.register)
          }
        }
        .padding()
      }
      .alert(
          self.store.scope(state: \.alert),
          dismiss: .alertCancelTapped
        )
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(
      store: .init(
        initialState: .init(),
        reducer: Login()
      )
    )
  }
}
