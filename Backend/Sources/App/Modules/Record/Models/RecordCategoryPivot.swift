//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 03/01/2023.
//

import Foundation
import FluentKit

// a pivot model for many-to-many reletionship.
final class RecordToCategoryPivot: DatabaseModelInterface {
  
  typealias Module = RecordModule
  
  struct FieldKeys {
    struct v1 {
      static var categoryID: FieldKey { "category_id" }
      static var recordID: FieldKey { "record_id" }
    }
  }
  
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: FieldKeys.v1.recordID)
  var record: RecordModel
  
  @Parent(key: FieldKeys.v1.categoryID)
  var category: RecordCategoryModel
  
  init() { }
  
  init(
    id: UUID? = nil,
    record: RecordModel,
    category: RecordCategoryModel
  ) throws {
    self.id = id
    self.$record.id = try record.requireID()
    self.$category.id = try category.requireID()
  }
}
