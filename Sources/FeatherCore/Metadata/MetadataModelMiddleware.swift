//
//  MetadataModelMiddleware.swift
//  FeatherCore
//
//  Created by Tibor Bodecs on 2020. 08. 29..
//

/// a viper model extension that can return a metadata object
public protocol MetadataRepresentable: ViperModel where Self.IDValue == UUID {

    var metadata: Metadata { get }
}

/// monitors model changes and calls the MetadataChangeDelegate if the metadata needs to be updated
public struct MetadataModelMiddleware<T: MetadataRepresentable>: ModelMiddleware {

    public init() {}

    /// on create action we call the willUpdate method using the delegate
    public func create(model: T, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        next.create(model, on: db).flatMap {
            var metadata = model.metadata
            metadata.id = UUID()
            metadata.module = T.Module.name
            metadata.model = T.name
            metadata.reference = model.id
            return Feather.metadataDelegate?.create(metadata, on: db) ?? db.eventLoop.future()
        }
    }
    
    /// on update action we call the willUpdate method using the delegate
    public func update(model: T, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        // NOTE: we don't want to update metadata info on model update
        next.update(model, on: db)//.flatMap {
//            var metadata = model.metadata
//            metadata.module = T.Module.name
//            metadata.model = T.name
//            metadata.reference = model.id
//            metadata.slug = nil
//            return Feather.metadataDelegate?.update(metadata, on: db) ?? db.eventLoop.future()
//        }
    }
    
    /// on delete action, we remove the associated metadata
    public func delete(model: T, force: Bool, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        next.delete(model, force: force, on: db).flatMap {
            var metadata = model.metadata
            metadata.module = T.Module.name
            metadata.model = T.name
            metadata.reference = model.id
            return Feather.metadataDelegate?.delete(metadata, on: db) ?? db.eventLoop.future()
        }
    }
}