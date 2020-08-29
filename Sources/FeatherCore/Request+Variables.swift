//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 08. 29..
//

import Vapor
import Fluent

public struct RequestVariablesMiddleware: Middleware {

    public func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        req.application.viper.invokeHook(name: "prepare-variables", req: req, type: Void.self)
//        SystemVariableModel.query(on: req.db).all().map { variables in
//            for variable in variables {
//                req.variables.cache.storage[variable.key] = variable.value
//            }
//        }
        .flatMap { _ in next.respond(to: req) }
    }
}

public extension Request {

    var variables: Variables {
        return .init(request: self)
    }

    struct Variables {
        let request: Request

        init(request: Request) {
            self.request = request
        }
    }
}

public extension Request.Variables {
    
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
        fileprivate var storage: [String: String] = [:]
    }

    func get(_ key: String) -> String {
        cache.storage[key] ?? ""
    }

    func has(_ key: String) -> Bool {
        cache.storage[key] != nil
    }

    func set(_ key: String, value: String, hidden: Bool? = nil, notes: String? = nil) -> EventLoopFuture<Void> {
        request.application.viper.invokeHook(name: "set-variable",
                                                  req: request,
                                                  type: Void.self,
                                                  params: ["key": key,
                                                           "value": value,
                                                           "hidden": hidden as Any,
                                                           "notes": notes as Any])
//        SystemVariableModel
//            .query(on: request.db)
//            .filter(\.$key == key)
//            .first()
//            .flatMap { model -> EventLoopFuture<Void> in
//                if let model = model {
//                    model.value = value
//                    if let hidden = hidden {
//                        model.hidden = hidden
//                    }
//                    model.notes = notes
//                    return model.update(on: request.db)
//                }
//                return SystemVariableModel(key: key,
//                                           value: value,
//                                           hidden: hidden ?? false,
//                                           notes: notes)
//                    .create(on: request.db)
//            }
            .map { _ in cache.storage[key] = value }
    }

    func unset(_ key: String) -> EventLoopFuture<Void> {
        request.application.viper.invokeHook(name: "unset-variable",
                                                  req: request,
                                                  type: Void.self,
                                                  params: ["key": key])
//        SystemVariableModel
//            .query(on: request.db)
//            .filter(\.$key == key)
//            .delete()
            .map { _ in cache.storage[key] = nil }
    }
}

