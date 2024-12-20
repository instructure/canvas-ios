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

public struct GetFrontPage: CollectionUseCase {
    public typealias Model = Page

    public let context: Context

    public init(context: Context) {
        self.context = context
    }

    public var cacheKey: String? {
        return "get-\(context.canvasContextID)-front_page"
    }

    public var request: GetFrontPageRequest {
        return GetFrontPageRequest(context: context)
    }

    public var scope: Scope {
        let contextID = NSPredicate(format: "%K == %@", #keyPath(Page.contextID), context.canvasContextID)
        let isFrontPage = NSPredicate(format: "%K == true", #keyPath(Page.isFrontPage))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [contextID, isFrontPage])
        let order = NSSortDescriptor(key: #keyPath(Page.title), ascending: true)
        return Scope(predicate: predicate, order: [order])
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APIPage?, URLResponse?, Error?) -> Void) {
        environment.api.makeRequest(request) { response, urlResponse, _ in
            completionHandler(response, urlResponse, nil) // no front page returns an error so ignore
        }
    }

    public func write(response: APIPage?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        let model = Page.save(response, in: client)
        model.contextID = context.canvasContextID
    }
}
