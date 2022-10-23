import Vapor
import VaporRouting
import SwiftHtml

enum AppRoute {
    case home
    case statistics
    case record(id: UUID)
}


let appRouter = OneOf {
    
    Route(.case(AppRoute.home)) {
        Path { "home" }
    }
    
    Route(.case(AppRoute.statistics)) {
        Path { "statistics" }
    }
    
    Route(.case(AppRoute.record)) {
        Path { "record"; "id"; UUID.parser(); }
    }
}

struct MyTemplate: TemplateRepresentable {
    let title: String
    func render(_ req: Request) -> Tag { Html {
        Head {
            Title(title)
        }
        Body {
            H1(title)
            H2("Dupa")
        }
    } }
}

// configures your application
public func configure(_ app: Application) throws {
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    
    // register routes
    try routes(app)
    app.mount(appRouter, use: appHandler)
}

func appHandler(
    request: Request,
    route: AppRoute
) async throws -> any AsyncResponseEncodable {
    switch route {
    case let .record(id: id):
        return RecordResponse(id: id)
    default:
        return NotFoundResponse()
    }
}


struct RecordResponse: Content{
    let id: UUID
    let title = "Nice title"
    let message = "Cool story bro"
}
struct NotFoundResponse: Content{
    let message = "Not found sorry mate"
}
