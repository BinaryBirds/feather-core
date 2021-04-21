//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 04. 09..
//

final class SystemModule: FeatherModule {

    static var moduleKey: String = "system"

    var bundleUrl: URL? {
        Bundle.module.resourceURL?.appendingPathComponent("Bundle")
    }

    func boot(_ app: Application) throws {
        /// middlewares
        app.middleware.use(SystemTemplateScopeMiddleware())
        app.middleware.use(SystemInstallGuardMiddleware())
        
        /// install
        app.hooks.register("install-permissions", use: installPermissionsHook)
        app.hooks.register("install-variables", use: installVariablesHook)
        /// admin menus
        app.hooks.register("admin-menus", use: adminMenusHook)
        /// routes
        let router = SystemRouter()
        try router.boot(routes: app.routes)
        app.hooks.register("routes", use: router.routesHook)
        app.hooks.register("admin-routes", use: router.adminRoutesHook)
        app.hooks.register("api-routes", use: router.apiRoutesHook)
        app.hooks.register("api-admin-routes", use: router.apiAdminRoutesHook)
        /// pages
        app.hooks.register("response", use: responseHook)
    }
  
    // MARK: - hooks
    
    func responseHook(args: HookArguments) -> EventLoopFuture<Response?> {
        let req = args.req

        /// if system is not installed yet, perform install process
        guard Application.Config.installed else {
            return SystemInstallController().performInstall(req: req).encodeOptionalResponse(for: req)
        }
        return req.eventLoop.future(nil)
    }
    

    #warning("add back permissions")
    func adminMenusHook(args: HookArguments) -> [FrontendMenu] {
        [
            .init(key: "system",
                  link: .init(label: "System",
                              url: "/admin/system/",
                              icon: "system",
                              permission: nil),
                  items: [
                    .init(label: "Dashboard",
                          url: "/admin/system/dashboard/",
                          permission: nil),
                    .init(label: "Settings",
                          url: "/admin/system/settings/",
                          permission: nil),
//                    .init(label: "Modules",
//                          url: "#",
//                          permission: nil),
//                    .init(label: "Tools",
//                          url: "#",
//                          permission: nil),
                  ]),
        ]
    }    
}
