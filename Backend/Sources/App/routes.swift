import Vapor
import VaporRouting

func routes(_ app: Application) throws {
//    app.get { req async in
//        "It works!"
//    }
//
//    app.get("hello") { req async -> String in
//        "Hello, world!"
//    }
    
    
//    app.routes.get("web") { req -> Response in
//        req.templates.renderHtml(MyTemplate(title: "Hello, World!"))
//    }
    
    
    app.routes.get("web") { req in
        req
            .templates
            .renderHtml(
                WebIndexTemplate(
                    .init(
                        title: "Home",
                        message: "Hi there, welcome to my page"
                    )
                )
            )
    }
}
