import Vapor
import VaporRouting
import SwiftHtml
import Fluent
import FluentSQLiteDriver

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


public func configure(_ app: Application) throws {
    
    let dbPath = app.directory.resourcesDirectory + "db.sqlite"
    app.databases.use(.sqlite(.file(dbPath)), as: .sqlite)
    
    app.middleware.use(
        FileMiddleware(
            publicDirectory: app.directory.publicDirectory
        )
    )
    
    app.middleware.use(
        ExtendPathMiddleware()
    )
    
    
    // register routes
    //    try routes(app)
    
    let modules: [ModuleInterface] = [
        WebModule(),
        BlogModule()
    ]
    for module in modules {
        try module.boot(app)
    }
    
    //    app.mount(appRouter, use: appHandler)
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
