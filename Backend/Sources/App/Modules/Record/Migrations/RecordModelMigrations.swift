//
//  RecordModelMigrations.swift
//  
//
//  Created by Tomek Kuzma on 27/12/2022.
//

import Vapor
import Fluent

enum RecordModelMigrations {
    
    struct v1: AsyncMigration {
        
        func prepare(on db: Database) async throws {
          
          var enumBuilder = db.enum("record_type")
          for option in RecordType.allCases {
              enumBuilder = enumBuilder.case(option.rawValue)
          }
          
          let recordType = try await enumBuilder
            .create()
          
          
          try await db.schema(RecordModel.schema)
              .id()
              .field(RecordModel.FieldKeys.v1.amount, .sql(raw: "NUMERIC(7,2)"), .required)
              .field(RecordModel.FieldKeys.v1.type, recordType, .required)
              .field(RecordModel.FieldKeys.v1.currency, .string, .required)
              .field(RecordModel.FieldKeys.v1.title, .string, .required)
              .field(RecordModel.FieldKeys.v1.notes, .string)
              .field(RecordModel.FieldKeys.v1.created, .string, .required)
              .field(RecordModel.FieldKeys.v1.updated, .string, .required)
              .field(RecordModel.FieldKeys.v1.deleted, .string)
              .field(RecordModel.FieldKeys.v1.userID, .uuid, .required)
              .foreignKey(RecordModel.FieldKeys.v1.userID, references: UserAccountModel.schema, .id)
              .create()
      
            try await db.schema(RecordCategoryModel.schema)
                .id()
                .field(RecordCategoryModel.FieldKeys.v1.name, .string, .required)
                .field(RecordCategoryModel.FieldKeys.v1.color, .int64, .required)
                .unique(on: RecordCategoryModel.FieldKeys.v1.name)
                .create()
          
          
          try await db.schema(RecordToCategoryPivot.schema)
              .id()
              .field(RecordToCategoryPivot.FieldKeys.v1.categoryID, .uuid, .required)
              .field(RecordToCategoryPivot.FieldKeys.v1.recordID, .uuid, .required)
              .foreignKey(RecordToCategoryPivot.FieldKeys.v1.categoryID, references: RecordCategoryModel.schema, .id)
              .foreignKey(RecordToCategoryPivot.FieldKeys.v1.recordID, references: RecordModel.schema, .id)
              .unique(on: RecordToCategoryPivot.FieldKeys.v1.recordID, RecordToCategoryPivot.FieldKeys.v1.categoryID)
              .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(RecordCategoryModel.schema).delete()
            try await db.schema(RecordModel.schema).delete()
            try await db.schema(RecordToCategoryPivot.schema).delete()
        }
    }
    
    struct seed: AsyncMigration {
        
        func prepare(on db: Database) async throws {
            let travel = RecordCategoryModel(name: "travel", color: 1)
            let food = RecordCategoryModel(name: "travel", color: 1)
            try await travel.create(on: db)
            try await food.create(on: db)
        }

        func revert(on db: Database) async throws {
            try await RecordModel.query(on: db).delete()
            try await RecordCategoryModel.query(on: db).delete()
        }
    }
    
}
