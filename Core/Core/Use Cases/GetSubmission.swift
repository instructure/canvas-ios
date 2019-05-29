//
// Copyright (C) 2018-present Instructure, Inc.
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

public class GetSubmission: APIUseCase {
    let context: Context
    let assignmentID: String
    let userID: String

    public typealias Model = Submission

    public init(context: Context, assignmentID: String, userID: String) {
        self.assignmentID = assignmentID
        self.userID = userID
        self.context = context
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
                #keyPath(Submission.assignmentID),
                assignmentID,
                #keyPath(Submission.userID),
                userID
            ),
            order: [NSSortDescriptor(key: #keyPath(Submission.attempt), ascending: false)]
        )
    }

    public func write(response: APISubmission?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }
        Submission.save(item, in: client)
    }
}
