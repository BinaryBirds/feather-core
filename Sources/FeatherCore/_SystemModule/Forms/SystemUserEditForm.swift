//
//  UserEditForm.swift
//  UserModule
//
//  Created by Tibor Bodecs on 2020. 03. 23..
//

final class SystemUserEditForm: EditForm {
    typealias Model = SystemUserModel

    var modelId: UUID?
    var email = TextField(key: "email", required: true)
    var password = TextField(key: "password")
    var root = ToggleField(key: "root")
    var roles = CheckboxField(key: "roles")
    var notification: String?

    var fields: [FormFieldRepresentable] {
        [email, password, root, roles]
    }

    init() {}

    func initialize(req: Request) -> EventLoopFuture<Void> {
        root.output.value = false
        return SystemRoleModel.query(on: req.db).all().mapEach(\.formFieldOption).map { [unowned self] in roles.output.options = $0 }
    }
    
    func validateAfterFields(req: Request) -> EventLoopFuture<Bool> {
        SystemUserModel.query(on: req.db).filter(\.$email == email.input.value!).first().map { [unowned self] model -> Bool in
            if (modelId == nil && model != nil) || (modelId != nil && model != nil && modelId! != model!.id) {
                email.output.error = "Email is already in use"
                return false
            }
            return true
        }
    }

    func read(from input: Model) {
        email.output.value = input.email
        root.output.value = input.root
        roles.output.values = input.roles.compactMap { $0.identifier }
    }

    func write(to output: Model) {
        output.email = email.input.value!
        output.root = root.input.value ?? false
        if let password = password.input.value, !password.isEmpty {
            output.password = try! Bcrypt.hash(password)
        }
    }

    func didSave(req: Request, model: Model) -> EventLoopFuture<Void> {
        var future = req.eventLoop.future()
        if modelId != nil {
            future = FeatherUserRoleModel.query(on: req.db).filter(\.$user.$id == modelId!).delete()
        }
        return future.flatMap { [unowned self] in
            #warning("fixme")
            return (roles.input.value ?? []).map { FeatherUserRoleModel(userId: model.id!, roleId: UUID(uuidString: $0)!) }.create(on: req.db)
        }
    }

}
