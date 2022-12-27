//
//  RecordCategoryModel.swift
//  
//
//  Created by Tomek Kuzma on 27/12/2022.
//

import Vapor
import Fluent
//
//final class RecordCategoryModel: DatabaseModelInterface {
//  typealias Module = RecordModule
//  
//  struct FieldKeys {
//    struct v1 {
//      static var name: FieldKey { "name" }
//      static var color: FieldKey { "color" }
//      static var recordID: FieldKey { "record_id" }
//    }
//  }
//  
//  @ID()
//  var id: UUID?
//  
//  @Field(key: FieldKeys.v1.name)
//  var name: String
//  
//  @Field(key: FieldKeys.v1.color)
//  var color: Int
//  
//  @Parent(key: FieldKeys.v1.recordID)
//  var record: RecordModel
//  
//  
//  init() { }
//  
//  init(
//    id: UUID? = nil,
//    name: String,
//    color: Int,
//    recordID: UUID
//  )
//  {
//    self.id = id
//    self.name = name
//    self.color = color
//    self.$record.id = recordID
//  }
//}
//

