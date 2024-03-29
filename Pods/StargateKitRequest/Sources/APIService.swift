/*
 * Copyright (C) PagesJaunes, SoLocal Group - All Rights Reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 */

public struct APIService<ResponseType: APIResponseValue> {

    public let id: String
    public let tag: String
    public let method: String
    public let path: String
    public let hasBody: Bool
    public let hasFile: Bool
    public let securityRequirement: SecurityRequirement?

    public init(id: String, tag: String = "", method:String, path:String, hasBody: Bool, hasFile: Bool = false, securityRequirement: SecurityRequirement? = nil) {
        self.id = id
        self.tag = tag
        self.method = method
        self.path = path
        self.hasBody = hasBody
        self.hasFile = hasFile
        self.securityRequirement = securityRequirement
    }
}

extension APIService: CustomStringConvertible {

    public var name: String {
        return "\(tag.isEmpty ? "" : "\(tag).")\(id)"
    }

    public var description: String {
        return "\(name): \(method) \(path)"
    }
}

public struct SecurityRequirement {
    public let type: String
    public let scope: String

    public init(type: String, scope: String) {
        self.type = type
        self.scope = scope
    }
}

