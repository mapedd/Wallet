//
//  main.swift
//
//
//  Created by Tibor Bodecs on 2021. 12. 25..
//

import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app, dateProvider: DateProvider(currentDate: { .now }))
try app.run()
