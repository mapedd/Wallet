//
//  WebLinkContext.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Foundation

public struct WebLinkContext {
    
    public let label: String
    public let url: String
    
    public init(
        label: String,
        url: String
    ) {
        self.label = label
        self.url = url
    }
}
