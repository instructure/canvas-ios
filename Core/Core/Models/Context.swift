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

    public var pathComponent: String {
        return "\(self)s"
    }
}

public protocol Context {
    var contextType: ContextType { get }
    var id: String { get }
}

public protocol APIContext: Context {
    var id: ID { get }
}
extension APIContext {
    var id: String { return id.value }
}

public extension Context {
    var canvasContextID: String {
        return "\(contextType)_\(id)"
    }

    var pathComponent: String {
        return "\(contextType.pathComponent)/\(id)"
    }
}
