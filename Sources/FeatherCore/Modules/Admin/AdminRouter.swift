//
//  AdminRouter.swift
//  Feather
//
//  Created by Tibor Bodecs on 2020. 04. 29..
//

struct AdminRouter: ViperRouter {
    
    let adminController = AdminController()

    func boot(routes: RoutesBuilder, app: Application) throws {

        /// protect admin routes through auth middlewares, if there was no auth middlewares returned we simply stop the registration
        guard let middlewares = app.viper.invokeSyncHook(name: "admin-auth-middlwares", type: [Middleware].self) else {
            return
        }
        /// groupd admin routes, first we use auth middlewares then the error middleware
        let protectedAdmin = routes.grouped("admin").grouped(middlewares).grouped(AdminErrorMiddleware())
        /// setup home view (dashboard)
        protectedAdmin.get(use: adminController.homeView)
        /// hook up other admin views that are protected by the authentication middleware
        try invoke(name: "admin", routes: protectedAdmin, app: app)
    }
}
