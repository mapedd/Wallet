//
//  SettingsView.swift
//  Wallet (iOS)
//
//  Created by Tomek Kuzma on 21/03/2023.
//

import SwiftUI
import WalletCore
import ComposableArchitecture

struct SettingsView : View {
  let store: StoreOf<Settings>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
//        Section(header: Text("Notifications settings")) {
//          Toggle(isOn: $settings.isNotificationEnabled) {
//            Text("Notification:")
//          }
//        }
        
        if viewStore.isLoggedIn {
          Section(header: Text(viewStore.headerCopy)) {
            Button(action: {
              viewStore.send(.logOutButtonTapped)
            }) {
              Text("Log out")
            }
          }
        }
      }
      .navigationBarTitle(Text("Settings"))
    }
    .alert(store: self.store.scope(state: \.alert, action: Settings.Action.alert))
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
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
    .padding(40)
  }
}
