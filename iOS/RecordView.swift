//
//  RecordListView.swift
//  Wallet
//
//  Created by Tomasz Kuzma on 02/09/2022.
//

import SwiftUI
import ComposableArchitecture

struct RecordView: View {
  var store: Store<RecordState, RecordAction>
  
  var friuts = ["hello", "my", "old", "friend"]
  
  @State var selection: String = "hello"
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        HStack {
          Text(viewStore.record.formattedCopy)
            .foregroundColor(viewStore.record.type == .income ? .green : .red)
          Spacer()
          
        }
        if let categoryName = viewStore.record.category?.name {
          Text(categoryName)
        }
      }
      .onTapGesture {
        viewStore.send(.setSheet(isPresented: true))
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isSheetPresented,
          send: RecordAction.setSheet(isPresented:)
        )
      ) {
        IfLetStore(
          self.store.scope(
            state: \.details,
            action: RecordAction.detailsAction
          )
        ) {
          RecordDetailsView(store: $0)
        }
      }
    }
  }
}


struct RecordView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      List {
        ForEach(RecordState.sample) { record in
          RecordView(
            store: .init(
              initialState: record,
              reducer: combinedRecordReducer,
              environment: RecordEnvironment()
            )
          )
        }
      }
    }
  }
}
