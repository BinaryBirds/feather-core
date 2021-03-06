////
////  FrontendPageEditForm.swift
////  FrontendModule
////
////  Created by Tibor Bodecs on 2020. 06. 09..
////

struct FrontendPageEditForm: FeatherForm {
    
    var context: FeatherFormContext<FrontendPageModel>
    
    init() {
        context = .init()
        context.form.fields = createFormFields()
    }

    private func createFormFields() -> [FormComponent] {
        [
            TextField(key: "title")
                .config { $0.output.required = true }
                .validators { [
                    FormFieldValidator.required($1),
                    FormFieldValidator($1, "Title must be unique", nil) { field, req in
                        guard Model.getIdParameter(req: req) == nil else {
                            return req.eventLoop.future(true)
                        }
                        return Model.isUniqueBy(\.$title == field.input, req: req)
                    }
                ] }
                .read { $1.output.value = context.model?.title }
                .write { context.model?.title = $1.input },

            ContentField(key: "content")
                .config { $0.output.required = true }
                .validators { [
                    FormFieldValidator.required($1),
                ] }
                .read { $1.output.value = context.model?.content }
                .write { context.model?.content = $1.input },
        ]
    }
}
