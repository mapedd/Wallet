//
//  File.swift
//  
//
//  Created by Tomek Kuzma on 29/01/2023.
//


import Vapor
import SwiftHtml

extension UserRecordsContext {
  var tableContext: TableContext {
    .init(
      columns: columns,
      rows: rows,
      actions: []
    )
  }
  
  var columns: [ColumnContext] {
    [
      .init("Name", label: "Name"),
      .init("Amount", label: "Amount"),
    ]
  }
  
  var rows: [RowContext] {
    records.map{ record in
        .init(
          id: record.id.uuidString,
          cells: [
            .init(record.title, link: nil),
            .init(record.formattedAmount, link: nil)
          ]
        )
    }
  }
}

extension Record.Detail {
  var sign: String {
    type == .expense ? "-" : "+"
  }
  var formattedAmount: String {
    sign + amount.formatted(.currency(code: currencyCode))
  }
}

struct UserRecordsTemplate: TemplateRepresentable {
    var context: UserRecordsContext
    
    init(_ context: UserRecordsContext) {
        self.context = context
    }

    @TagBuilder
    func render(_ req: Request) -> Tag {
        WebIndexTemplate(.init(title: context.title)) {
            Div {
                Section {
                    H1(context.title)
                }
                .class("lead")
//
//                Div {
//                    for record in context.records {
//                        Article {
//                            A {
////                                Img(src: post.image, alt: post.title)
//                                H2(record.title)
//                                H3(record.amount.formatted(.currency(code: record.currencyCode)))
//                                P(record.notes)
//                            }
//                            .href("/\(record.id.uuidString)/")
//                        }
//                    }
//                }
//                .class("grid-221")
              
              TableTemplate(context.tableContext).render(req)
              
              Section {
                H2(context.total)
              }
                
            }
            .id("records")
        }
        .render(req)
    }
}

