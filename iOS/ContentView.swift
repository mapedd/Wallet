//
//  ContentView.swift
//  Shared
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture
import IdentifiedCollections

struct ContentView: View {
  var body: some View {
    NavigationView {
      MainView(
        store: .init(
          initialState: .init(
            editorState: .init(),
            records: [],
            summaryState: .init(),
            title: "Wallet"
          ),
          reducer: mainReducer,
          environment: MainEnvironment()
        )
      )
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
