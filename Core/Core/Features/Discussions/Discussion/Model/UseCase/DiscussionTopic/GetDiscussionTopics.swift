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

class GetDiscussionTopics: CollectionUseCase {
    typealias Model = DiscussionTopic
    typealias Response = Request.Response

    let context: Context
    init(context: Context) {
        self.context = context
    }

    var cacheKey: String? { "\(context.pathComponent)/discussions" }
    var request: GetDiscussionTopicsRequest {
        GetDiscussionTopicsRequest(context: context)
    }
    var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(DiscussionTopic.isAnnouncement), equals: false),
            NSPredicate(key: #keyPath(DiscussionTopic.canvasContextID), equals: context.canvasContextID)
        ]),
        order: [
            NSSortDescriptor(key: #keyPath(DiscussionTopic.orderSection), ascending: true),
            NSSortDescriptor(key: #keyPath(DiscussionTopic.position), ascending: true),
            NSSortDescriptor(key: #keyPath(DiscussionTopic.order), ascending: false, naturally: true)
        ],
        sectionNameKeyPath: #keyPath(DiscussionTopic.orderSection)
    ) }
}
