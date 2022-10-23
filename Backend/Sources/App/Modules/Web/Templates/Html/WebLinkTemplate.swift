//
//  WebLinkTemplate.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Foundation
import Vapor
import SwiftHtml

struct WebLinkTemplate: TemplateRepresentable {
    var context: WebLinkContext
    
    init(_ context: WebLinkContext) {
        self.context = context
    }
    
    @TagBuilder
    func render(_ req: Request) -> Tag {
        A(context.label)
            .href(context.url)
    }
    
}
