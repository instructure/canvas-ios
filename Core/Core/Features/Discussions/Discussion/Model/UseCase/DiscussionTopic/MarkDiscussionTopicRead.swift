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

class MarkDiscussionTopicRead: APIUseCase {
    var cacheKey: String? { nil }
    let context: Context
    let request: MarkDiscussionTopicReadRequest
    let topicID: String

    init(context: Context, topicID: String, isRead: Bool) {
        self.context = context
        self.request = MarkDiscussionTopicReadRequest(context: context, topicID: topicID, isRead: isRead)
        self.topicID = topicID
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if context.contextType == .course {
            NotificationCenter.default.post(moduleItem: .discussion(topicID), completedRequirement: .view, courseID: context.id)
        }
        NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
    }
}
