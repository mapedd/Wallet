//
//  Request+Template.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Vapor

public extension Request {
    var templates: TemplateRenderer { .init(self) }
}
