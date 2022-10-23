//
//  WebFrontendController.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Vapor

struct WebFrontendController {
    func homeView(req: Request) throws -> Response {
        
        
        let ctx = WebHomeContext(
            icon: "🤑",
            title: "Home",
            message: "Hi, welcome to my page",
            paragraphs: [
                "Lorem ipsum dolor sit amet, consectetur adipiscing",
                "Lorem ipsum dolor sit amet, consectetur adipiscing",
                "Lorem ipsum dolor sit amet, consectetur adipiscing"
            ],
            link: .init(
                label: "Read my blog →",
                url: "/blog"
            )
        )
        
        return  req
            .templates
            .renderHtml(
                WebHomeTemplate(ctx)
            )
    }
}
