//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public class PutSubmissionComment: APIUseCase {
    public var cacheKey: String?

    public typealias Model = SubmissionComment

    let courseID: String
    let assignmentID: String
    let userID: String

    let text: String
    let isGroupComment: Bool
    let attempt: Int?

    public init(
        courseID: String,
        assignmentID: String,
        userID: String,
        text: String,
        isGroupComment: Bool,
        attempt: Int?
    ) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        self.text = text
        self.isGroupComment = isGroupComment
        self.attempt = attempt
    }

    public var request: PutSubmissionGradeRequest {
        return PutSubmissionGradeRequest(
            courseID: courseID,
            assignmentID: assignmentID,
            userID: userID,
            body: .init(
                comment: PutSubmissionGradeRequest.Body.Comment(
                    text: text,
                    forGroup: isGroupComment,
                    attempt: attempt
                )
            )
        )
    }
    
    public func write(
        response: APISubmission?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let item = response else {
            return
        }
        Submission.save(item, in: client)
    }
}
