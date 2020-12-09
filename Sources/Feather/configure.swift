//
//  configure.swift
//  Feather
//
//  Created by Tibor Bodecs on 2019. 12. 17..
//

import FeatherCore
import LeafFoundation
/// drivers
import FluentSQLiteDriver
import LiquidLocalDriver


public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.fileStorages.use(.local(publicUrl: Application.baseUrl,
                                publicPath: app.directory.publicDirectory,
                                workDirectory: "assets"), as: .local)

    app.routes.defaultMaxBodySize = "10mb"

    app.sessions.use(.fluent)
    app.migrations.add(SessionRecord.migration)
    app.middleware.use(SlashMiddleware())
    app.middleware.use(RequestCacheMiddleware())
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(LeafFoundationMiddleware())
    

    let modules: [ViperModule] = [
        ///core modules (do not remove them)
        UserBuilder(),
        SystemBuilder(),
        AdminBuilder(),
        ApiBuilder(),
        FrontendBuilder(),
    ].map { $0.build() }
    
    let defaultSource = NIOLeafFiles(fileio: app.fileio,
                               limits: [.requireExtensions],
                               sandboxDirectory: app.directory.resourcesDirectory,
                               viewDirectory: app.directory.viewsDirectory,
                               defaultExtension: "html")

    let multipleSources = LeafSources()
    try multipleSources.register(using: defaultSource)

    for module in modules {
        guard let url = module.bundleUrl else { continue }

        let moduleSource = ViperBundledLeafSource(module: module.name,
                                                  rootDirectory: url.path.withTrailingSlash,
                                                  templatesDirectory: "Templates",
                                                  fileExtension: "html",
                                                  fileio: app.fileio)

        try multipleSources.register(source: "\(module.name)-module-bundle", using: moduleSource)
    }

    LeafEngine.sources = multipleSources
    LeafEngine.useLeafFoundation()
    LeafEngine.entities.use(ResolveLeafEntity(), asMethod: "resolve")
    LeafEngine.entities.use(InvokeHookLeafEntity(), asFunction: "InvokeHook")
    LeafEngine.entities.use(InvokeAllHooksLeafEntity(), asFunction: "InvokeAllHooks")
    LeafEngine.entities.use(InlineSvg(iconset: "feather-icons"), asFunction: "svg")
    LeafEngine.entities.use(UserHasPermissionLeafEntity(), asFunction: "UserHasPermission")
    LeafRenderer.Option.timeout = 1.000 // 1000ms

    if app.isDebug {
        LeafRenderer.Option.caching = .bypass
    }
    app.views.use(.leaf)
    
    try app.viper.use(modules)

    app.middleware.use(FeatherCoreLeafExtensionMiddleware())
    app.middleware.use(ViperLeafScopesMiddleware())    
        
    try app.autoMigrate().wait()
}


