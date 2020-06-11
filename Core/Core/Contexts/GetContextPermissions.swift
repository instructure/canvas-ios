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

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APIPermissions?, URLResponse?, Error?) -> Void) {
        environment.api.makeRequest(request, refreshToken: false, callback: completionHandler)
    }

    public func write(response: APIPermissions?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }
        Permissions.save(item, for: context, in: client)
    }
}
