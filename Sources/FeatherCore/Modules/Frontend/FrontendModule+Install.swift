//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 04. 21..
//

extension FrontendModule {
        
    func installModelsHook(args: HookArguments) -> EventLoopFuture<Void> {
        let req = args.req
        
        let mainId = UUID()
        let mainMenu = FrontendMenuModel(id: mainId, key: "main", name: "Main menu")
        
        /// gather the main menu items through a hook function then map them
        let menuItems: [[MenuItemCreateObject]] = req.invokeAll(.installMainMenuItems, args: ["menuId": mainId])
        var mainMenuItemModels = menuItems.flatMap { $0 }.compactMap {
            FrontendMenuItemModel(icon: $0.icon, label: $0.label, url: $0.url, priority: $0.priority, isBlank: $0.isBlank, menuId: $0.menuId)
        }
        
        /// we add an about menu item
        let aboutMenuItem = FrontendMenuItemModel(label: "About", url: "/about/", priority: 0, menuId: mainId)
        mainMenuItemModels.insert(aboutMenuItem, at: 0)
        
        let footerId = UUID()
        let footerMenu = FrontendMenuModel(id: footerId, key: "footer", name: "Footer menu")
        
        let footerItems = [
            FrontendMenuItemModel(label: "Sitemap", url: "/sitemap.xml", priority: 1000, isBlank: true, menuId: footerId),
            FrontendMenuItemModel(label: "RSS", url: "/rss.xml", priority: 900, isBlank: true, menuId: footerId),
        ]
        
        /// we expect a key-value array of static page install elements with title and content keys
        let pages: [[PageCreateObject]] = req.invokeAll(.installPages)
        var pageModels = pages.flatMap({ $0 }).map {
            FrontendPageModel(title: $0.title, content: $0.content)
        }
        
        /// create home page with a hookable page content
        let homePage = FrontendPageModel(title: "Home", content: "[home-page]")
        
        /// create a sample about page
        let aboutPage = FrontendPageModel(title: "About", content: "About.html")
        pageModels.append(aboutPage)

        /// we persist the pages to the database
        return req.eventLoop.flatten([
            /// save home page and set it as a published root page by altering the metadata
            homePage.create(on: req.db).flatMap {
                homePage.publishMetadataAsHome(on: req.db)
            },
            /// save pages, then we publish the associated metadatas
            pageModels.create(on: req.db).flatMap { _ in
                req.eventLoop.flatten(pageModels.map { $0.publishMetadata(on: req.db) })
            },
            /// finally create menu items
            [mainMenu, footerMenu].create(on: req.db).flatMap {
                (mainMenuItemModels + footerItems).create(on: req.db)
            },
        ])
    }
    
    func installPermissionsHook(args: HookArguments) -> [PermissionCreateObject] {
        var permissions: [PermissionCreateObject] = [
            FrontendModule.hookInstallPermission(for: .custom("admin"))
        ]
        permissions += FrontendMetadataModel.hookInstallPermissions()
        permissions += FrontendMenuModel.hookInstallPermissions()
        permissions += FrontendMenuItemModel.hookInstallPermissions()
        permissions += FrontendPageModel.hookInstallPermissions()
        return permissions
    }
    
    func installVariablesHook(args: HookArguments) -> [VariableCreateObject] {
        [
            .init(key: "homePageIcon",
                  name: "Home page icon",
                  value: "🪶",
                  notes: "Icon of the home page"),

            .init(key: "homePageTitle",
                  name: "Home page title",
                  value: "Welcome",
                  notes: "Title of the home page"),
            
            .init(key: "homePageExcerpt",
                  name: "Home page excerpt",
                  value: "This is your brand new Feather CMS powered website",
                  notes: "Excerpt for the home page"),

            .init(key: "homePageLinkLabel",
                  name: "Home page link label",
                  value: "Start customizing →",
                  notes: "Link label of the home page"),

            .init(key: "homePageLinkUrl",
                  name: "Home page link url",
                  value: "/admin/",
                  notes: "Link URL of the home page"),
        ]
    }

}
