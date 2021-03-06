//
//  UserAdminController.swift
//  UserModule
//
//  Created by Tibor Bodecs on 2020. 03. 23..
//


struct UserAccountController: FeatherController {

    typealias Module = UserModule
    typealias Model = UserAccountModel
    
    typealias CreateForm = UserAccountEditForm
    typealias UpdateForm = UserAccountEditForm
    
    typealias GetApi = UserAccountApi
    typealias ListApi = UserAccountApi
    typealias CreateApi = UserAccountApi
    typealias UpdateApi = UserAccountApi
    typealias PatchApi = UserAccountApi
    typealias DeleteApi = UserAccountApi

    // MARK: - login

    func login(req: Request) throws -> EventLoopFuture<TokenObject> {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        let tokenValue = [UInt8].random(count: 16).base64
        let token = UserTokenModel(value: tokenValue, userId: user.id)
        return token.create(on: req.db).map { token.getContent }
    }
    
    // MARK: - api
    
    func findBy(_ id: UUID, on db: Database) -> EventLoopFuture<Model> {
        Model.findWithRolesBy(id: id, on: db).unwrap(or: Abort(.notFound, reason: "User not found"))
    }

    func afterCreate(req: Request, form: CreateForm, model: Model) -> EventLoopFuture<Model> {
        findBy(model.id!, on: req.db)
    }

    func afterUpdate(req: Request, form: UpdateForm, model: Model) -> EventLoopFuture<Model> {
        findBy(model.id!, on: req.db)
    }

    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        Model.query(on: req.db).count().flatMap { count in
            if count == 1 {
                return req.eventLoop.future(error: Abort(.badRequest, reason: "You can't delete every user"))
            }
            return UserTokenModel.query(on: req.db).filter(\.$user.$id == model.id!).delete().map { model }
        }
    }

    
    func listTable(_ models: [Model]) -> Table {
        Table(columns: ["email"], rows: models.map { model in
            TableRow(id: model.identifier, cells: [TableCell(model.email)])
        })
    }

    func detailFields(req: Request, model: Model) -> [DetailContext.Field] {
        [
            .init(label: "Id", value: model.identifier),
            .init(label: "Email", value: model.email),
            .init(label: "Has root access?", value: model.root ? "Yes" : "No"),
            .init(label: "Roles", value: model.roles.map(\.name).joined(separator: "<br>")),
        ]
    }
    
    func deleteContext(req: Request, model: UserAccountModel) -> String {
        model.email
    }

}
