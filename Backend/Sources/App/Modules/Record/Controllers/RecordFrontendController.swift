//
//  RecordFrontendController.swift
//  
//
//  Created by Tomek Kuzma on 29/01/2023.
//


import Vapor
import Fluent

struct RecordFrontendController {
  
  var recordAPIController: RecordAPIController
  
  func totalTitle(_ sum: Decimal, code: String) -> String {
    "Total: \(sum.formatted(.currency(code: code)))"
  }
  
  func recordsView(req: Request) async throws -> Response {
    
    let list = try await recordAPIController.list(req: req)
    
    let code = "USD"
    
    let conversions = try await req.conversions(query: .init(baseCurrency: code, currencies: []))
    
    let sum = list.reduce(Decimal.zero, { partialResult, record in
      let recordCurrency = record.currencyCode
     guard
      let conversion: Float = conversions.data[recordCurrency]
      else {
        return partialResult
      }
      let convertedAmount = record.amount / Decimal(floatLiteral: Double(conversion))
      if record.type == .expense {
        return partialResult - convertedAmount
      } else if record.type == .income {
        return partialResult + convertedAmount
      } else {
        fatalError("not handled record type")
      }
    })
    
    
    let ctx = UserRecordsContext(
      title: "Records",
      total: totalTitle(sum, code: code),
      records: list
    )
    
    
    return req.templates.renderHtml(UserRecordsTemplate(ctx))
  }
  
  //    func postView(req: Request) async throws -> Response? {
  //        let slug = req.url.path.trimmingCharacters(in: .init(charactersIn: "/"))
  //        guard
  //            let post = try await BlogPostModel
  //                .query(on: req.db)
  //                .filter(\.$slug == slug)
  //                .first()
  //        else {
  //            return nil
  //        }
  //        let model = try await BlogPostApiController().detailOutput(req, post)
  //        let context = BlogPostContext(post: model)
  //        return req.templates.renderHtml(BlogPostTemplate(context))
  //    }
}

