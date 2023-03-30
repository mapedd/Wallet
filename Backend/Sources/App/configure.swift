//
//  configure.swift
//
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import Vapor
import Fluent
import FluentSQLiteDriver
//import SendGrid
import Liquid
import LiquidLocalDriver
@_exported import AppApi


extension Environment {
  var isComingSoon: Bool {
    Environment.get("COMING_SOON") != nil
  }
  
  var emailsDisabled: Bool {
    Environment.get("DISABLE_EMAILS") != nil
  }
  
  var mailerSendApiKey: String? {
    if self == .testing {
      return "TEST_API_KEY"
    } else {
      return Environment.get("MAILERSEND_API_KEY")
    }
  }
}

public func configure(_ app: Application, dateProvider: DateProvider) throws {
  
  if app.environment == .testing {
    app.databases.use(.sqlite(.memory), as: .sqlite)
  } else {
    /// setup Fluent with a SQLite database under the Resources directory
    
    let directory = app.directory.resourcesDirectory
    
    var isDir:ObjCBool = true
    if !FileManager.default.fileExists(atPath: directory, isDirectory: &isDir) {
      app.logger.notice("directory \(directory) for db does not exist, creating it")
      try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
    } else {
      app.logger.notice("directory \(directory) for db does exist")
    }
    
    if app.environment.isComingSoon {
      app.logger.notice("coming soon mode enabled")
    } else {
      app.logger.notice("coming soon mode disabled")
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
  
  let webSocketManager = WebsocketManager(app: app)
  app.websocketManager = webSocketManager
  
  app.webSocket("channel") { _, ws in
    webSocketManager.connect(ws)
  }
//
//  app.sendgrid.initialize()
  
  /// use automatic database migration
  try app.autoMigrate().wait()
}

