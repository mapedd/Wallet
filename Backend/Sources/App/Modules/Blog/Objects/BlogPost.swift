//
//  BlogPost.swift
//  
//
//  Created by Tomek Kuzma on 26/10/2022.
//

import Foundation

extension Blog.Post {
    struct Detail: Codable {
        let id: UUID
        let title: String
        let slug: String
        let image: String
        let excerpt: String
        let date: Date
        let category: Blog.Category.List
        let content: String
    }
}
