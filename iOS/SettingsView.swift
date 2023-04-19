//
//  SettingsView.swift
//  Wallet (iOS)
//
//  Created by Tomek Kuzma on 21/03/2023.
//

import SwiftUI
import WalletCore
import ComposableArchitecture
import UIKit


struct SettingsView : View {
  let store: StoreOf<Settings>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Section(header: Text("Import & Export")) {
          Button(action: {
            viewStore.send(.importFromFileRowTapped)
          }) {
            Text("Import from file (*.csv)")
          }
        }
        
        if viewStore.isLoggedIn {
          Section(header: Text(viewStore.headerCopy)) {
            Button(action: {
              viewStore.send(.logOutButtonTapped)
            }) {
              Text("Log out")
            }
            
            Button(action: {
              viewStore.send(.deleteAccountRowTapped)
            }) {
              Text("Delete account")
            }
          }
          
        }
      }
      .navigationBarTitle(Text("Settings"))
    }
    .sheet(
      store: self.store.scope(state: \.picker, action: Settings.Action.picker)
    ) { store in
      DocumentPickerView(store: store)
    }
    .alert(store: self.store.scope(state: \.alert, action: Settings.Action.alert))
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SettingsView(
        store: .init(
          initialState: .init(
            user: UserModel(
              email: "email@email.com",
              id: .init()
            )
          ),
          reducer: Settings()
        )
      )
    }
  }
}
