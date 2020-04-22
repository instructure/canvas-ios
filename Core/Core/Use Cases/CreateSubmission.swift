//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public class CreateSubmission: APIUseCase {
    let context: Context
    let assignmentID: String
    let userID: String
    public let request: CreateSubmissionRequest
    public typealias Model = Submission

    public init(context: Context, assignmentID: String, userID: String,
                submissionType: SubmissionType,
                textComment: String? = nil,
                body: String? = nil,
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

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APISubmission?, URLResponse?, Error?) -> Void) {
        environment.api.makeRequest(request) { [weak self] response, urlResponse, error in
            guard let self = self else { return }
            if error == nil {
                NotificationCenter.default.post(moduleItem: .assignment(self.assignmentID), completedRequirement: .submit, courseID: self.context.id)
                NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
            }
            completionHandler(response, urlResponse, error)
        }
    }

    public func write(response: APISubmission?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }
        Submission.save(item, in: client)
    }
}
