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

import Foundation
import CoreData

public class GetSubmissionComments: APIUseCase {
    let assignmentID: String
    let context: Context
    let submissionID: String
    let userID: String

    public typealias Model = SubmissionComment

    public init(context: Context, assignmentID: String, userID: String, submissionID: String) {
        self.assignmentID = assignmentID
        self.context = context
        self.submissionID = submissionID
        self.userID = userID
    }

    public var cacheKey: String? {
        return "get-\(context.id)-\(assignmentID)-\(userID)-submission"
    }

    public var request: GetSubmissionRequest {
        return GetSubmissionRequest(context: context, assignmentID: assignmentID, userID: userID)
    }

    public var scope: Scope {
        return Scope(
            predicate: NSPredicate(format: "%K == %@", #keyPath(SubmissionComment.submissionID), submissionID),
            order: [NSSortDescriptor(key: #keyPath(SubmissionComment.createdAt), ascending: false)]
        )
    }

    public func write(response: APISubmission?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        Submission.save(item, in: client)
    }
}
