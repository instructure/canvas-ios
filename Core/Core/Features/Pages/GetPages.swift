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
import CoreData

public struct GetPages: CollectionUseCase {
    public typealias Model = Page

    public let context: Context

    public init(context: Context) {
        self.context = context
    }

    public var cacheKey: String? {
        return "get-\(context.canvasContextID)-pages"
    }

    public var request: GetPagesRequest {
        return GetPagesRequest(context: context)
    }

    public var scope: Scope {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(Page.contextID), equals: context.canvasContextID),
            NSPredicate(format: "%K == false", #keyPath(Page.isFrontPage))
        ])
        return Scope(predicate: predicate, orderBy: #keyPath(Page.title), naturally: true)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping ([APIPage]?, URLResponse?, Error?) -> Void) {
        environment.api.makeRequest(request) { (response, urlResponse, error) in
            if (urlResponse as? HTTPURLResponse)?.statusCode == 404 {
                completionHandler(response, urlResponse, nil) // always returns error when no pages exist so ignore
            } else {
                completionHandler(response, urlResponse, error)
            }
        }
    }
}
