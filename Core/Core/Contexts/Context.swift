//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

public enum ContextType: String, Codable {
    case account, course, group, user, section, folder

    public init?(pathComponent: String) {
        guard pathComponent.last == "s" else { return nil }
        self.init(rawValue: String(pathComponent.dropLast()))
    }

    public var pathComponent: String { "\(self)s" }
}

public struct Context: Codable, Equatable, Hashable {
    public let contextType: ContextType
    public let id: String

    public var canvasContextID: String { "\(contextType)_\(id)"  }
    public var pathComponent: String { "\(contextType.pathComponent)/\(id)" }

    public init(_ contextType: ContextType, id: String) {
        if id.isEmpty {
            RemoteLogger.shared.logError(
                name: "Context created with invalid contextId",
                reason: "contextType: \(contextType.rawValue), contextId: \"\(id)\", baseUrl: \(Analytics.analyticsBaseUrl)"
            )
        }

        self.contextType = contextType
        self.id = ID.expandTildeID(id)
    }

    public init?(_ contextType: ContextType, id: String?) {
        guard let id else { return nil }
        self.init(contextType, id: id)
    }

    public init?(url: URL) {
        self.init(path: url.path)
    }

    public init?(path: String) {
        self.init(parts: path.split(separator: "/").filter({ (s: Substring) in s != "api" && s != "v1" }))
    }

    public init?(canvasContextID: String) {
        self.init(parts: canvasContextID.split(separator: "_"))
    }

    private init?(parts: [Substring]) {
        guard parts.count >= 2 else { return nil }
        let rawValue = parts[0].lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "s"))
        guard let contextType = ContextType(rawValue: rawValue) else { return nil }
        self.init(contextType, id: String(parts[1]))
    }
}

public extension Context {
    static func account(_ id: String) -> Context { Context(.account, id: id) }
    static func course(_ id: String) -> Context { Context(.course, id: id) }
    static func group(_ id: String) -> Context { Context(.group, id: id) }
    static func user(_ id: String) -> Context { Context(.user, id: id) }
    static let currentUser = Context.user("self")

    var accountId: String? { contextType == .account ? id : nil }
    var courseId: String? { contextType == .course ? id : nil }
    var groupId: String? { contextType == .group ? id : nil }
    var userId: String? { contextType == .user ? id : nil }

    var isValid: Bool {
        id.isNotEmpty
    }
}
