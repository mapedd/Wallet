//
//  WebIndexContext.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Foundation

public struct WebIndexContext {
    public let title: String
    public let message: String
    
    public init(
        title: String,
        message: String
    ) {
        self.title = title
        self.message = message
    }
}
