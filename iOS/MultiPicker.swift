//
//  MultiPicker.swift
//  Wallet (iOS)
//
//  Created by Tomek Kuzma on 18/01/2023.
//

import SwiftUI

protocol Readable {
  var readableDescription: String { get }
}

struct MultiPicker<T: Identifiable & Readable> : View {
  
  init(
    label: String,
    options: [T],
    pickedValues: [T],
    itemTapped: @escaping (T) -> Void
  ) {
    self.label = label
    self.options = options
    self.pickedValues = pickedValues
    self.itemTapped = itemTapped
  }
  
  private var label: String
  private var options: [T]
  private var pickedValues: [T]
  private var itemTapped: (T) -> Void

  private func isSelected(element: T) -> Bool {
    pickedValues.contains { inside in
      inside.id == element.id
    }
  }

  var body: some View {
    Menu {
      ForEach(options) { element in
        Button(
          action: {
            itemTapped(element)
          },
          label: {
            if isSelected(element: element) {
              Text("\(String.checkmark) " + element.readableDescription)
            }else {
              Text(element.readableDescription)
            }
          }
        )
        .buttonStyle(.plain)
      }
    } label: {
      Text(label)
    }
  }
}


extension String {
  static let checkmark = "✔"
}

