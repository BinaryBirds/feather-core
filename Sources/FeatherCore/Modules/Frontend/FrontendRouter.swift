//
//  FrontendRouter.swift
//  Feather
//
//  Created by Tibor Bodecs on 2020. 01. 26..
//

struct FrontendRouter: ViperRouter {
    
    let frontendController = FrontendController()
    var adminController = FrontendMetadataAdminController()

    func boot(routes: RoutesBuilder, app: Application) throws {
        /// register not found middleware for every unhandled case
        var frontendMiddlewares: [Middleware] = [FrontendNotFoundMiddleware()]
        
        /// if there are other middlewares we add them before the not found handler
        if let middlewares = app.viper.invokeSyncHook(name: "frontend-middlwares", type: [Middleware].self) {
            frontendMiddlewares.insert(contentsOf: middlewares, at: 0)
        }

        let frontendRoutes = routes.grouped(frontendMiddlewares)

        /// handle root path and everything else via the controller method
        frontendRoutes.get(use: frontendController.catchAllView)
        frontendRoutes.get(.catchall, use: frontendController.catchAllView)

        /// register public sitemap and rss routes
        routes.get("sitemap.xml", use: frontendController.sitemap)
        routes.get("rss.xml", use: frontendController.rss)
    }

    func hook(name: String, routes: RoutesBuilder, app: Application) throws {
        switch name {
        case "admin":
            /// setup admin interface for frontend content models
            let adminModule = routes.grouped(FrontendModule.pathComponent)
            adminController.setupRoutes(on: adminModule, as: "metadatas")
        default:
            break;
        }
    }
}

