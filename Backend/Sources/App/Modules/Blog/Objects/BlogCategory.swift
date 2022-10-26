//
//  BlogCategory.swift
//  
//
//  Created by Tomek Kuzma on 26/10/2022.
//

import Foundation

extension Blog {
    enum Category {
        
    }
}
extension Blog.Category {
    struct List: Codable {
        let id: UUID
        let title: String
    }
}
