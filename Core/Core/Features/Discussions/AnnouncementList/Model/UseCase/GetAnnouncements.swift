//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class GetAnnouncements: CollectionUseCase {
    typealias Model = DiscussionTopic

    let context: Context
    init(context: Context) {
        self.context = context
    }

    var cacheKey: String? { "\(context.pathComponent)/announcements" }
    var request: GetDiscussionTopicsRequest {
        GetDiscussionTopicsRequest(context: context, isAnnouncement: true)
    }
    var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(DiscussionTopic.isAnnouncement), equals: true),
            NSPredicate(key: #keyPath(DiscussionTopic.canvasContextID), equals: context.canvasContextID)
        ]),
        orderBy: #keyPath(DiscussionTopic.position), ascending: true
    ) }

    func write(response: [APIDiscussionTopic]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        let pageOffset: Int = {
            guard
                let url = urlResponse?.url,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let pageSize = components.pageSize
            else {
                return 0
            }

            return (components.page - 1) * pageSize
        }()

        response?.enumerated().forEach {
            Model.save($0.element, apiPosition: pageOffset + $0.offset, in: client)
        }
    }
}
