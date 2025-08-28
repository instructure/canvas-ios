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
import Combine
import UIKit

public class CreateSubmission: APIUseCase {
    let context: Context
    let assignmentID: String
    let userID: String
    let moduleID: String?
    let moduleItemID: String?
    public let request: CreateSubmissionRequest
    public typealias Model = Submission

    private var subscriptions = Set<AnyCancellable>()

    public init(
        context: Context,
        assignmentID: String,
        userID: String,
        submissionType: SubmissionType,
        textComment: String? = nil,
        isGroupComment: Bool? = nil,
        body: String? = nil,
        url: URL? = nil,
        fileIDs: [String]? = nil,
        mediaCommentID: String? = nil,
        mediaCommentType: MediaCommentType? = nil,
        annotatableAttachmentID: String? = nil,
        moduleID: String? = nil,
        moduleItemID: String? = nil
    ) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        self.moduleID = moduleID
        self.moduleItemID = moduleItemID

        let submission = CreateSubmissionRequest.Body.Submission(
            annotatable_attachment_id: annotatableAttachmentID,
            text_comment: textComment,
            group_comment: isGroupComment,
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

    public var scope: Scope { Scope(
        predicate: NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(Submission.assignmentID), assignmentID,
            #keyPath(Submission.userID), userID
        ),
        orderBy: #keyPath(Submission.attempt),
        ascending: false
    ) }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APISubmission?, URLResponse?, Error?) -> Void) {

        environment.api.makeRequest(request) { [weak self] response, urlResponse, error in
            guard let self = self else { return }

            if error == nil {
                NotificationCenter.default.post(moduleItem: .assignment(self.assignmentID), completedRequirement: .submit, courseID: self.context.id)
                if let moduleID = self.moduleID, let moduleItemID = self.moduleItemID {
                    NotificationCenter.default.post(
                        name: .moduleItemRequirementCompleted,
                        object: ModuleItemAttributes(
                            courseID: self.context.id,
                            moduleID: moduleID,
                            itemID: moduleItemID
                        )
                    )
                } else {
                    NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
                }
            }

            UIAccessibility
                .announceSubmission(isSuccessful: response != nil && error == nil)
                .sink {
                    completionHandler(response, urlResponse, error)
                }
                .store(in: &subscriptions)
        }
    }

    public func write(response: APISubmission?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else {
            return
        }
        Submission.save(item, in: client)
        if item.late != true {
            NotificationCenter.default.post(name: .celebrateSubmission, object: nil, userInfo: [
                "assignmentID": assignmentID
            ])
        }
    }
}
