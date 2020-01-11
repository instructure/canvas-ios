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

public struct GetSearchRecipients: CollectionUseCase {
    public typealias Request = APISearchRecipientsRequestable
    public typealias Model = SearchRecipient

    enum ContextQualifier {
        case teachers, students, observers
    }

    public let context: Context
    public let contextQualifier: APISearchRecipientsRequestable.ContextQualifier?
    public let userID: String?

    public init(context: Context, contextQualifier: APISearchRecipientsRequestable.ContextQualifier? = nil, userID: String? = nil) {
        self.context = context
        self.contextQualifier = contextQualifier
        self.userID = userID
    }

    public var cacheKey: String? {
        return "get-\(context.canvasContextID)-search-recipients"
    }

    public var request: APISearchRecipientsRequestable {
        return APISearchRecipientsRequestable(context: context, contextQualifier: contextQualifier, userID: userID)
    }

    public var scope: Scope {
        return .where(#keyPath(SearchRecipient.filter), equals: filter, orderBy: #keyPath(SearchRecipient.fullName))
    }

    public func write(response: [APISearchRecipient]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        for item in response {
            SearchRecipient.save(item, filter: filter, in: client)
        }
    }

    var filter: String {
        var components = URLComponents()
        components.queryItems = request.queryItems
        return components.url?.absoluteString ?? ""
    }
}
