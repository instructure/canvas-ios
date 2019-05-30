//
// Copyright (C) 2019-present Instructure, Inc.
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

import CoreData
import Foundation

public struct GetContextPermissions: APIUseCase {
    public typealias Model = Permissions

    let context: Context
    let permissions: [PermissionName]

    public init(context: Context, permissions: [PermissionName] = []) {
        self.context = context
        self.permissions = permissions
    }

    public var cacheKey: String? {
        return "get-\(context.canvasContextID)-permissions-\(permissions.map({ $0.rawValue }).sorted().joined(separator: ","))"
    }

    public var request: GetContextPermissionsRequest {
        return GetContextPermissionsRequest(context: context, permissions: permissions)
    }

    public var scope: Scope {
        return Scope(
            predicate: NSPredicate(format: "%K == %@", #keyPath(Permissions.context), context.canvasContextID),
            order: []
        )
    }

    public func write(response: APIPermissions?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }
        Permissions.save(item, for: context, in: client)
    }
}
