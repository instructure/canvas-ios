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

import CoreData
import Foundation

public class GetCustomColors: APIUseCase {
    public typealias Model = ContextColor

    public let request = GetCustomColorsRequest()
    public let scope = Scope.all(orderBy: #keyPath(ContextColor.canvasContextID))
    public let cacheKey: String? = "get-custom-colors"

    public init() {}

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping (APICustomColors?, URLResponse?, Error?) -> Void
    ) {
        // Always call root account API for this request.
        environment.root.api.makeRequest(request, callback: completionHandler)
    }

    public func write(response: APICustomColors?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        ContextColor.save(response, in: client)
    }
}
