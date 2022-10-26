//
//  BlogCategoryModel.swift
//  
//
//  Created by Tomek Kuzma on 25/10/2022.
//

import Foundation

import Vapor
import Fluent

final class BlogCategoryModel: DatabaseModelInterface {
    
    typealias Module = BlogModule
    
    struct FieldKeys {
        struct v1 {
            static var title: FieldKey { "title" }
        }
        
    }
    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.title) var title: String
    @Children(for: \.$category) var posts: [BlogPostModel]
    
    init() { }
    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
        
    }
}
