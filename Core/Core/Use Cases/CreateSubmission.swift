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

public class CreateSubmission: APIUseCase {
    let context: Context
    let assignmentID: String
    let userID: String
    public let request: CreateSubmissionRequest
    public typealias Model = Submission

    public init(context: Context, assignmentID: String, userID: String,
                textComment: String? = nil,
                body: String? = nil,
                submissionType: SubmissionType,
                url: URL? = nil,
                fileIDs: [String]? = nil,
                mediaCommentID: String? = nil,
                mediaCommentType: MediaCommentType? = nil) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID

        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: textComment,
            submission_type: submissionType,
            body: body,
            url: url,
            file_ids: fileIDs,
            media_comment_id: mediaCommentID,
            media_comment_type: mediaCommentType
        )

        request = CreateSubmissionRequest(
            context: context,
            assignmentID: assignmentID,
            body: .init(submission: submission)
        )
    }

    public var cacheKey: String?

    public var scope: Scope {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(Submission.assignmentID), assignmentID, #keyPath(Submission.userID), userID)
        let sort = NSSortDescriptor(key: #keyPath(Submission.attempt), ascending: false)
        return Scope(predicate: predicate, order: [sort])
    }

    public func write(response: APISubmission?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let item = response, let context = client as? NSManagedObjectContext else {
            return
        }
        Submission.save(item, in: context)
        Logger.shared.log("created a submission")
    }
}
