//
//  TextareaFieldTemplate.swift
//  
//
//  Created by Tomek Kuzma on 01/11/2022.
//

import Vapor
import SwiftHtml
import SwiftUI

public struct TextareaFieldTemplate: TemplateRepresentable, TemplateRepresentablePreviewable {
    
    public var context: TextareaFieldContext
    
    public init(_ context: TextareaFieldContext) {
        self.context = context
    }
    
    @TagBuilder
    public func render(_ req: Request) -> Tag {
        render()
    }
    
    @TagBuilder
    public func render() -> Tag {
        LabelTemplate(context.label)
            .render()
        
        Textarea(context.value)
            .placeholder(context.placeholder)
            .name(context.key)
        
        if let error = context.error {
            Span(error)
                .class("error")
        }
    }
}

struct TextareaFieldTemplate_Previews: PreviewProvider {    
    static var previews: some SwiftUI.View {
      WebView(
        tag: TextareaFieldTemplate(
            .init(
                key: "key",
                label: .init(
                    key: "label",
                    title: "title",
                    required: true,
                    more: "more"),
                placeholder: "placeholder",
                value: "value",
                error: nil
            )
        ).render()
      )
  }
}


import WebKit

struct WebView : NSViewRepresentable {
    
    let tag: Tag
    
    func makeNSView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        
        let doc = Document(.html) { tag }
        let body = DocumentRenderer(
            minify: false,
            indent: 0
        ).render(doc)
        
        nsView.loadHTMLString(body, baseURL: nil)
    }
    
}
