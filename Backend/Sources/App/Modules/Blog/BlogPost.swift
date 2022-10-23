//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Foundation

struct BlogPost: Codable {
    let title: String
    let slug: String
    let image: String
    let excerpt: String
    let date: Date
    let category: String?
    let content: String
}
