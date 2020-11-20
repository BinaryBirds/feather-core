//
//  FrontendContentEditForm.swift
//  Feather
//
//  Created by Tibor Bodecs on 2020. 06. 09..
//

final class FrontendMetadataEditForm: ModelForm {

    typealias Model = Metadata
    
    struct Input: Decodable {
        var modelId: String
        var module: String
        var model: String
        var reference: String
        var slug: String
        var title: String
        var excerpt: String
        var canonicalUrl: String
        var statusId: String
        var filters: [String]
        var date: String
        var feedItem: String
        var css: String
        var js: String

        var image: File?
        var imageDelete: Bool?
    }

    var modelId: String? = nil
    var module = StringFormField()
    var model = StringFormField()
    var reference = StringFormField()
    var slug = StringFormField()
    var title = StringFormField()
    var excerpt = StringFormField()
    var canonicalUrl = StringFormField()
    var statusId = StringSelectionFormField()
    var feedItem = StringSelectionFormField()
    var filters = StringArraySelectionFormField()
    var date = StringFormField()
    var image = FileFormField()
    var css = StringFormField()
    var js = StringFormField()
    var notification: String?
    var dateFormat: String?
    
    var leafData: LeafData {
        .dictionary([
            "modelId": modelId,
            "module": module,
            "model": model,
            "reference": reference,
            "slug": slug,
            "title": title,
            "excerpt": excerpt,
            "canonicalUrl": canonicalUrl,
            "statusId": statusId,
            "feedItem": feedItem,
            "filters": filters,
            "date": date,
            "css": css,
            "js": js,
            "image": image,
            "notification": notification,
            "dateFormat": dateFormat,
        ])
    }

    init() {
        initialize()
    }

    init(req: Request) throws {
        initialize()

        let context = try req.content.decode(Input.self)
        modelId = context.modelId.emptyToNil
        module.value = context.module
        model.value = context.model
        reference.value = context.reference
        slug.value = context.slug
        statusId.value = context.statusId
        filters.values = context.filters
        date.value = context.date
        title.value = context.title
        excerpt.value = context.excerpt
        canonicalUrl.value = context.canonicalUrl
        feedItem.value = context.feedItem
        css.value = context.css
        js.value = context.js

        image.delete = context.imageDelete ?? false
        if let img = context.image, let data = img.data.getData(at: 0, length: img.data.readableBytes), !data.isEmpty {
            image.data = data
        }
    }

    func initialize() {
        dateFormat = Application.Config.dateFormatter().dateFormat
        statusId.options = Model.Status.allCases.map(\.formFieldStringOption)
        statusId.value = Model.Status.draft.rawValue
        date.value = Application.Config.dateFormatter().string(from: Date())
        feedItem.options = FormFieldStringOption.trueFalse()
    }
    
    func validate(req: Request) -> EventLoopFuture<Bool> {
        var valid = true
       
        if module.value.isEmpty {
            module.error = "Module is required"
            valid = false
        }
        if Validator.count(...250).validate(module.value).isFailure {
            module.error = "Module is too long (max 250 characters)"
            valid = false
        }
        if model.value.isEmpty {
            model.error = "Model is required"
            valid = false
        }
        if Validator.count(...250).validate(model.value).isFailure {
            model.error = "Model is too long (max 250 characters)"
            valid = false
        }
        if UUID(uuidString: reference.value) == nil {
            reference.error = "Invalid reference"
            valid = false
        }
        if Bool(feedItem.value) == nil {
            feedItem.error = "Invalid feed item value"
            valid = false
        }
        if Model.Status(rawValue: statusId.value) == nil {
            statusId.error = "Invalid status"
            valid = false
        }
        if Application.Config.dateFormatter().date(from: date.value) == nil {
            date.error = "Invalid date"
            valid = false
        }
        if Validator.count(...250).validate(slug.value).isFailure {
            slug.error = "Slug is too long (max 250 characters)"
            valid = false
        }
        if Validator.count(...250).validate(title.value).isFailure {
            title.error = "Title is too long (max 250 characters)"
            valid = false
        }
        if Validator.count(...250).validate(canonicalUrl.value).isFailure {
            canonicalUrl.error = "Canonical URL is too long (max 250 characters)"
            valid = false
        }
        return req.eventLoop.future(valid)
    }
    
    func read(from input: Model)  {
        modelId = input.id?.uuidString
        module.value = input.module
        model.value = input.model
        reference.value = input.reference.uuidString
        slug.value = input.slug
        statusId.value = input.status.rawValue
        feedItem.value = String(input.feedItem)
        filters.values = input.filters
        date.value = Application.Config.dateFormatter().string(from: input.date)
        title.value = input.title ?? ""
        excerpt.value = input.excerpt ?? ""
        canonicalUrl.value = input.canonicalUrl ?? ""
        image.value = input.imageKey ?? ""
        css.value = input.css ?? ""
        js.value = input.js ?? ""
    }

    func write(to output: Model) {
        output.module = module.value
        output.model = model.value
        output.reference = UUID(uuidString: reference.value)!
        output.slug = slug.value
        output.status = Model.Status(rawValue: statusId.value)!
        output.feedItem = Bool(feedItem.value)!
        output.filters = filters.values
        output.date = Application.Config.dateFormatter().date(from: date.value)!
        output.title = title.value.emptyToNil
        output.excerpt = excerpt.value.emptyToNil
        output.canonicalUrl = canonicalUrl.value.emptyToNil
        output.css = css.value.emptyToNil
        output.js = js.value.emptyToNil
    }
}
