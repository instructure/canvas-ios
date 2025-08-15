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

public class GetSubmissionComments: APIUseCase {
    let assignmentID: String
    let context: Context
    let userID: String
    let isAscendingOrder: Bool

    public typealias Model = SubmissionComment

    public init(context: Context, assignmentID: String, userID: String, isAscendingOrder: Bool = false) {
        self.assignmentID = assignmentID
        self.context = context
        self.userID = userID
        self.isAscendingOrder = isAscendingOrder
    }

    public var cacheKey: String? {
        return "get-\(context.id)-\(assignmentID)-\(userID)-submission"
    }

    public var request: GetSubmissionRequest {
        return GetSubmissionRequest(context: context, assignmentID: assignmentID, userID: userID)
    }

    public var scope: Scope {
        return Scope(
            predicate: NSPredicate(
                format: "%K == %@ AND %K == %@",
                #keyPath(SubmissionComment.assignmentID),
                assignmentID,
                #keyPath(SubmissionComment.userID),
                userID
            ),
            order: [NSSortDescriptor(key: #keyPath(SubmissionComment.createdAt), ascending: isAscendingOrder)]
        )
    }

    public func write(response: APISubmission?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        Submission.save(item, in: client)
    }
}
