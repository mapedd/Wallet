//
//  RecordCategoryModel.swift
//  
//
//  Created by Tomek Kuzma on 27/12/2022.
//

import Vapor
import Fluent

final class RecordCategoryModel: DatabaseModelInterface {
  typealias Module = RecordModule
  
  struct FieldKeys {
    struct v1 {
      static var name: FieldKey { "name" }
      static var color: FieldKey { "color" }
    }
  }
  
  @ID()
  var id: UUID?
  
  @Field(key: FieldKeys.v1.name)
  var name: String
  
  @Field(key: FieldKeys.v1.color)
  var color: Int
  
  @Siblings(through: RecordToCategoryPivot.self, from: \.$category, to: \.$record)
  var records: [RecordModel]
  
  init() { }
  
  init(
    id: UUID? = nil,
    name: String,
    color: Int
  ) {
    self.id = id
    self.name = name
    self.color = color
  }
}


