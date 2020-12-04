//
//  MenuEditForm.swift
//  Feather
//
//  Created by Tibor Bodecs on 2020. 11. 15..
//

final class MenuItemEditForm: ModelForm<MenuItemModel> {

    struct Input: Decodable {
        var modelId: UUID?
        var icon: String
        var label: String
        var url: String
        var priority: Int
        var targetBlank: Bool
        var permission: String
        var menuId: UUID
    }

    var icon = FormField<String>(key: "icon")
    var label = FormField<String>(key: "label").required().length(max: 250)
    var url = FormField<String>(key: "url").required().length(max: 250)
    var priority = FormField<Int>(key: "priority")
    var targetBlank = FormField<Bool>(key: "targetBlank")
    var permission = FormField<String>(key: "permission").length(max: 250)
    var menuId = FormField<UUID>(key: "menuId")
    
    required init() {
        super.init()
        initialize()
    }

    required init(req: Request) throws {
        try super.init(req: req)
        initialize()

        let context = try req.content.decode(Input.self)
        modelId = context.modelId
        icon.value = context.icon
        label.value = context.label
        url.value = context.url
        priority.value = context.priority
        targetBlank.value = context.targetBlank
        permission.value = context.permission
        menuId.value = context.menuId
    }

    func initialize() {
        targetBlank.options = FormFieldOption.trueFalse()
        targetBlank.value = false
        priority.value = 100
    }

    override func fields() -> [FormFieldInterface] {
        [icon, label, url, priority, targetBlank, permission, menuId]
    }

    override func read(from input: Model)  {
        modelId = input.id
        icon.value = input.icon
        label.value = input.label
        url.value = input.url
        priority.value = input.priority
        targetBlank.value = input.targetBlank
        permission.value = input.permission
        menuId.value = input.$menu.id
    }

    override func write(to output: Model) {
        output.icon = icon.value?.emptyToNil
        output.label = label.value!
        output.url = url.value!
        output.priority = priority.value!
        output.targetBlank = targetBlank.value!
        output.permission = permission.value?.emptyToNil
        output.$menu.id = menuId.value!
    }
}
