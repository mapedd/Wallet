//
//  BlogFrontendController.swift
//  
//
//  Created by Tomek Kuzma on 23/10/2022.
//

import Vapor
import Fluent

struct BlogFrontendController {
    var posts: [BlogPost] {
        stride(from: 1, to: 9, by: 1).map{ index in
            BlogPost(
                title: "Sample post #\(index)",
                slug: "sample-post-\(index)",
                image: "/img/posts/\(String(format: "%02d", index + 1)).jpg",
                excerpt: "Lorem ipsum",
                date: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 60))),
                category: Bool.random() ? "Sample category" : nil,
                content: "Lorem ipsum dolor sit amet."
            )
        }
        .sorted() { $0.date > $1.date }
    }
    
    func blogView(req: Request) async throws -> Response {
        let postModels = try await BlogPostModel
            .query(on: req.db)
            .sort(\.$date, .descending)
            .all()
        
        let posts = postModels.map {
            Blog.Post.List(
                id: $0.id!,
                title: $0.title,
                slug: $0.slug,
                image: $0.imageKey,
                excerpt: $0.excerpt,
                date: $0.date
            )
        }
        
        let ctx = BlogPostsContext(
            icon: "🔥 ",
            title: "Blog",
            message: "Hot news and stories about everything",
            posts: posts
        )
        
        return req.templates.renderHtml(BlogPostsTemplate(ctx))
    }
    
    func postView(req: Request) async throws -> Response {
        
        let slug = req.url.path.trimmingCharacters(in: .init(charactersIn: "/"))
        
        guard
            let post = try await BlogPostModel
                .query(on: req.db)
                .filter(\.$slug == slug)
                .with(\.$category)
                .first()
        else {
            return req.redirect(to: "/")
        }
        
        let ctx = BlogPostContext(
            post: Blog.Post.Detail(
                id: post.id!,
                title: post.title,
                slug: post.slug,
                image: post.imageKey,
                excerpt: post.excerpt,
                date: post.date,
                category: .init(
                    id: post.category.id!,
                    title: post.category.title
                ),
                content: post.content
            )
        )
        return req.templates.renderHtml(BlogPostTemplate(ctx))
    }
}
