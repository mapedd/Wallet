//
//  configure.swift
//
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import Vapor
import Fluent
import FluentSQLiteDriver
import Liquid
import LiquidLocalDriver
@_exported import AppApi

public func configure(_ app: Application, dateProvider: DateProvider) throws {
  
  if app.environment == .testing {
    app.databases.use(.sqlite(.memory), as: .sqlite)
  } else {
    /// setup Fluent with a SQLite database under the Resources directory
    
    let directory = app.directory.resourcesDirectory
    
    var isDir:ObjCBool = true
    if !FileManager.default.fileExists(atPath: directory, isDirectory: &isDir) {
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
    }
    
    let dbPath = directory + "db.sqlite"
    app.databases.use(.sqlite(.file(dbPath)), as: .sqlite)
  }
  
  /// setup Liquid using the local file storage driver
  app.fileStorages.use(.local(publicUrl: "http://localhost:8080",
                              publicPath: app.directory.publicDirectory,
                              workDirectory: "assets"), as: .local)
  
  /// set the max file upload limit
  app.routes.defaultMaxBodySize = "10mb"
  
  /// use the Public directory to serve public files
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  
  /// extend paths to always contain a trailing slash
//  app.middleware.use(ExtendPathMiddleware())
  
  /// setup sessions
  app.sessions.use(.fluent)
  app.migrations.add(SessionRecord.migration)
  app.middleware.use(app.sessions.middleware)
  
  
  
  /// setup modules
  let modules: [ModuleInterface] = [
    WebModule(),
    UserModule(router: .init(dateProvider: dateProvider)),
    AdminModule(),
    ApiModule(),
    BlogModule(),
    RecordModule(router: .init(dateProvider: dateProvider)),
    CurrencyModule(router: .init(dateProvider: dateProvider))
  ]
  for module in modules {
    try module.boot(app)
  }
  for module in modules {
    try module.setUp(app)
  }
  
  app.routes.get("shutdown") { req in
    app.shutdown()
    return ""
  }
  
  /// use automatic database migration
  try app.autoMigrate().wait()
}

