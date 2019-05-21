//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public enum ContextType: String {
    case account, course, group, user, section

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
