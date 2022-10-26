//
//  Blog.swift
//  
//
//  Created by Tomek Kuzma on 26/10/2022.
//

import Foundation

enum Blog {
    enum Post {
        
    }
}

extension Blog.Post {
    struct List: Codable {
        let id: UUID
        let title: String
        let slug: String
        let image: String
        let excerpt: String
        let date: Date
    }
}
