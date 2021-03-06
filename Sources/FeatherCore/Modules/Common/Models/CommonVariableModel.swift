//
//  SystemVariableModel.swift
//  SystemModule
//
//  Created by Tibor Bödecs on 2020. 06. 10..
//

final class CommonVariableModel: FeatherModel {
    typealias Module = CommonModule

    static let modelKey: String = "variables"
    static let name: FeatherModelName = "Variable"

    struct FieldKeys: TimestampFieldKeys {
        static var key: FieldKey { "key" }
        static var name: FieldKey { "name" }
        static var value: FieldKey { "value" }
        static var notes: FieldKey { "notes" }
    }

    // MARK: - fields

    @ID() var id: UUID?
    @Field(key: FieldKeys.key) var key: String
    @Field(key: FieldKeys.name) var name: String
    @OptionalField(key: FieldKeys.value) var value: String?
    @OptionalField(key: FieldKeys.notes) var notes: String?
    
    @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?
    @Timestamp(key: FieldKeys.updatedAt, on: .update) var updatedAt: Date?
    @Timestamp(key: FieldKeys.deletedAt, on: .delete) var deletedAt: Date?


    init() {}

    init(id: UUID? = nil,
         key: String,
         name: String,
         value: String? = nil,
         notes: String? = nil)
    {
        self.id = id
        self.key = key
        self.name = name
        self.value = value
        self.notes = notes
    }
    
    // MARK: - query

    static func allowedOrders() -> [FieldKey] {
        [
            FieldKeys.name,
            FieldKeys.key,
        ]
    }
    
    static func search(_ term: String) -> [ModelValueFilter<CommonVariableModel>] {
        [
            \.$name ~~ term,
            \.$key ~~ term,
            \.$value ~~ term,
            \.$notes ~~ term,
        ]
    }
}

