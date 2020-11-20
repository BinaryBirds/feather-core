//
//  FrontendModule.swift
//  Feather
//
//  Created by Tibor Bodecs on 2020. 01. 26..
//

public final class FrontendModule: ViperModule {

    public static let name = "frontend"
    public var priority: Int { 100 }
    
    public var router: ViperRouter? = FrontendRouter()
    
    public var migrations: [Migration] {
        Metadata.migrations()
    }
    
    public var viewsUrl: URL? {
        nil
//        Bundle.module.bundleURL
//            .appendingPathComponent("Contents")
//            .appendingPathComponent("Resources")
//            .appendingPathComponent("Views")
    }
    
    public func invokeSync(name: String, req: Request?, params: [String : Any]) -> Any? {
        switch name {
        case "leaf-admin-menu":
            return [
                "name": "Frontend",
                "icon": "layout",
                "items": LeafData.array([
                    [
                        "url": "/admin/frontend/metadatas/",
                        "label": "Metadatas",
                    ],
                ])
            ]
        default:
            return nil
        }
    }
}

