//
//  TemplateRepresentable.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Vapor
import SwiftSgml

public protocol TemplateRepresentable {
    @TagBuilder
    func render(_ req: Request) -> Tag
    
}
