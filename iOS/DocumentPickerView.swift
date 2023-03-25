//
//  DocumentPickerView.swift
//  Wallet (iOS)
//
//  Created by Tomek Kuzma on 25/03/2023.
//

import SwiftUI
import WalletCore
import ComposableArchitecture
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
  func makeCoordinator() -> Coordinator {
    Coordinator(viewStore: viewStore)
  }
  
  let store: StoreOf<DocumentPicker>
  
  @StateObject var viewStore: ViewStoreOf<DocumentPicker>
  
  init(store: StoreOf<DocumentPicker>) {
    self.store = store
    let viewStore = ViewStore(self.store, observe: { $0 })
    self._viewStore = StateObject(wrappedValue: viewStore)
    
  }
  
  
  func makeUIViewController(context: Self.Context) -> UIDocumentPickerViewController {
    
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text])
    
    picker.allowsMultipleSelection = false
    picker.delegate = context.coordinator
    return picker
  }
  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Self.Context) {
    
  }
  
  class Coordinator: NSObject, UIDocumentPickerDelegate {
    let viewStore: ViewStoreOf<DocumentPicker>
    init(viewStore: ViewStoreOf<DocumentPicker>) {
      self.viewStore = viewStore
      super.init()
    }
    private func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: [URL]) {
      print(urls)
    }
  }
}
