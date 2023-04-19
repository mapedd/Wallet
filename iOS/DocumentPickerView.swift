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
    Coordinator(pickerView: self)
  }
  
  let store: StoreOf<DocumentPicker>
  let viewStore: ViewStoreOf<DocumentPicker>
  
  init(store: StoreOf<DocumentPicker>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
//    self._viewStore = StateObject(wrappedValue: viewStore)
    
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
    let pickerView: DocumentPickerView
    init(pickerView: DocumentPickerView) {
      self.pickerView = pickerView
      self.viewStore = pickerView.viewStore
      super.init()
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      self.viewStore.send(.selected(urls))
    }
  }
}
