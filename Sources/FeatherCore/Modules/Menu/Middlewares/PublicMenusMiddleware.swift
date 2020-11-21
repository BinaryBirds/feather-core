//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 11. 15..
//

public struct PublicMenusMiddleware: Middleware {
    
    public init() {}
    
    public func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let future: EventLoopFuture<[String:LeafDataRepresentable]> = req.invoke("prepare-menus") else {
            return next.respond(to: req)
        }
        return future.flatMap { items in
            for variable in items {
                req.menus.cache.storage[variable.key] = variable.value
            }
            return next.respond(to: req)
        }
    }
}

public extension Request {

    var menus: Menus {
        return .init(request: self)
    }

    struct Menus {
        let request: Request

        init(request: Request) {
            self.request = request
        }
    }
}

public extension Request.Menus {
    
    private struct CacheKey: StorageKey {
        typealias Value = Cache
    }

    fileprivate var cache: Cache {
        get {
            if let existing = request.storage[CacheKey.self] {
                return existing
            }
            let new = Cache()
            request.storage[CacheKey.self] = new
            return new
        }
        set {
            request.storage[CacheKey.self] = newValue
        }
    }

    fileprivate final class Cache {
        fileprivate var storage: [String:LeafDataRepresentable] = [:]
    }

    var all: [String:LeafDataRepresentable] { cache.storage }
}

