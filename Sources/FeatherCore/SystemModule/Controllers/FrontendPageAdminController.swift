//
//  FrontendPageAdminController.swift
//  FrontendModule
//
//  Created by Tibor Bodecs on 2020. 06. 09..
//




struct FrontendPageAdminController: AdminViewController {
    
    typealias Module = SystemModule
    typealias Model = SystemPageModel
    typealias CreateForm = SystemPageEditForm
    typealias UpdateForm = SystemPageEditForm
    
//    var listAllowedOrders: [FieldKey] = [
//        Model.FieldKeys.title,
//    ]
//    
//    func listQuery(search: String, queryBuilder: QueryBuilder<SystemPageModel>, req: Request) {
//        queryBuilder.filter(\.$title ~~ search)
//    }

    func listTable(_ models: [Model]) -> Table {
        Table(columns: ["title"], rows: models.map { model in
            TableRow(id: model.id!.uuidString, cells: [TableCell(model.title)])
        })
    }
    
    func deleteContext(req: Request, model: Model, formId: String, formToken: String) -> DeleteControllerContext {
        .init(id: formId,
              token: formToken,
              context: model.title,
              type: "page",
              list: .init(title: "Pages", url: "/admin/system/pages")
        )
    }
}
