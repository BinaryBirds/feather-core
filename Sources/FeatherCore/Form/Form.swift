//
//  Form.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 22..
//

open class Form: FormComponent {

    /// used to validate form token (nonce) values
    struct IdTokenInput: Decodable {

        /// identifier of the form
        let formId: String
        /// associated token for the form
        let formToken: String
    }
    
    public struct Action: Encodable {
        public enum Method: String, Encodable {
            case get
            case post
        }
        public var method: Method
        public var url: String?
        public var multipart: Bool
        
        public init(method: Method = .post,
                    url: String? = nil,
                    multipart: Bool = false) {
            self.method = method
            self.url = url
            self.multipart = multipart
        }
    }
    
    enum CodingKeys: CodingKey {
        case action
        case id
        case token
        case title
        case notification
        case error
        case fields
        case submit
    }

    open var action: Action
    open var id: String
    open var token: String
    open var notification: Notification?
    open var error: String?

    open var submit: String?

    open var fields: [FormComponent] {
        didSet {
            /// NOTE: maybe a requiresMultipart: Bool FormComponent protocol property would be a better idea... ?
            self.action.multipart = fields.reduce(false, { $0 || ($1 is ImageField || $1 is FileField || $1 is MultifileField) })
        }
    }

    public init(action: Action = .init(),
                id: String = UUID().uuidString,
                token: String = UUID().uuidString,
                notification: Notification? = nil,
                error: String? = nil,
                fields: [FormComponent] = [],
                submit: String? = nil) {
        
        self.action = action
        self.id = id
        self.token = token
        self.notification = notification
        self.error = error
        self.fields = fields
        self.submit = submit
    }

    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(action, forKey: .action)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(notification, forKey: .notification)
        try container.encodeIfPresent(error, forKey: .error)
        try container.encodeIfPresent(submit, forKey: .submit)

        var fieldsArrayContainer = container.superEncoder(forKey: .fields).unkeyedContainer()
        for field in fields {
            try field.encode(to: fieldsArrayContainer.superEncoder())
        }
    }
    
    public func validateToken(_ req: Request) throws {
        let context = try req.content.decode(IdTokenInput.self)
        try req.useNonce(id: context.formId, token: context.formToken)
    }
    
    // MARK: - form component
    
    open func load(req: Request) -> EventLoopFuture<Void> {
        token = req.generateNonce(for: id)
        return req.eventLoop.flatten(fields.map { $0.load(req: req) })
    }

    open func process(req: Request) -> EventLoopFuture<Void> {
        req.eventLoop.flatten(fields.map { $0.process(req: req) })
    }
    
    open func validate(req: Request) -> EventLoopFuture<Bool> {
        do {
            try validateToken(req)
            return req.eventLoop.mergeTrueFutures(fields.map { $0.validate(req: req) })
        }
        catch {
            return req.eventLoop.future(error: error)
        }
    }

    open func save(req: Request) -> EventLoopFuture<Void> {
        req.eventLoop.flatten(fields.map { $0.save(req: req) })
    }
    
    open func read(req: Request) -> EventLoopFuture<Void> {
        req.eventLoop.flatten(fields.map { $0.read(req: req) })
    }

    open func write(req: Request) -> EventLoopFuture<Void> {
        req.eventLoop.flatten(fields.map { $0.write(req: req) })
    }
}
