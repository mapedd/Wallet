//
//  Login.swift
//  Wallet
//
//  Created by Tomek Kuzma on 20/12/2022.
//

import SwiftUI
import ComposableArchitecture
import WalletCore

struct LoginView: View {
  var store: StoreOf<Login>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section {
          TextField("Email",
            text: viewStore.binding(\.$username)
          )
          .autocapitalization(.none)
          .disableAutocorrection(true)
          .keyboardType(.emailAddress)
          
          SecureField("Password",
            text: viewStore.binding(\.$password)
          )
          .submitLabel(.go)
          .onSubmit {
            viewStore.send(.passwordSubmitted)
          }
        }
        .disabled(viewStore.textFieldsDisabled)
        
        Section {
          HStack {
            Button("Log me in ") {
              viewStore.send(.logIn)
            }
            .disabled(!viewStore.buttonsEnabled)
            Spacer()
            if viewStore.loggingIn {
              ProgressView()
            }
          }
        }
        
        Section {
          HStack {
            Button("Register ") {
              viewStore.send(.register)
            }
            .disabled(!viewStore.buttonsEnabled)
            Spacer()
            if viewStore.registering {
              ProgressView()
            }
          }
        }
        
        Section(content: {}, header: {
          Text(viewStore.footerText)
        }) {}
      }
      .task {
        viewStore.send(.task)
      }
      .alert(store: self.store.scope(state: \.alert, action: Login.Action.alert))
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LoginView(
        store: .init(
          initialState: .init(),
          reducer: Login()
        )
      )
      .navigationTitle("Wallet")
    }
  }
}
