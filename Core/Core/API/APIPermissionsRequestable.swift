//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/all_resources.html#method.accounts.permissions
// https://canvas.instructure.com/doc/api/all_resources.html#method.courses.permissions
// https://canvas.instructure.com/doc/api/all_resources.html#method.groups.permissions
public struct GetContextPermissionsRequest: APIRequestable {
    public typealias Response = APIPermissions

    let context: Context
    let permissions: [PermissionName]

    public init(context: Context, permissions: [PermissionName] = []) {
        self.context = context
        self.permissions = permissions
    }

    public var path: String {
        return "\(context.pathComponent)/permissions"
    }

    public var query: [APIQueryItem] {
        guard permissions.count > 0 else {
            return []
        }

        return [.array("permissions", permissions.map { $0.rawValue })]
    }
}
