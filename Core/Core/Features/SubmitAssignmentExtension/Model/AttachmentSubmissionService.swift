//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class AttachmentSubmissionService {
    private let submissionAssembly: FileSubmissionAssembly
    private var existingSubmissionID: NSManagedObjectID?

    public init(submissionAssembly: FileSubmissionAssembly) {
        self.submissionAssembly = submissionAssembly
    }

    /**
     - returns: The `FileSubmission` CoreData object for the newly created submission.
     */
    public func submit(
        urls: [URL],
        courseID: String,
        assignmentID: String,
        assignmentName: String,
        comment: String?,
        isGroupComment: Bool?
    ) -> NSManagedObjectID {
        if let existingSubmissionID = existingSubmissionID {
            submissionAssembly.composer.deleteSubmission(submissionID: existingSubmissionID)
        }

        let submissionID = submissionAssembly.composer.makeNewSubmission(
            courseId: courseID,
            assignmentId: assignmentID,
            assignmentName: assignmentName,
            comment: comment,
            isGroupComment: isGroupComment,
            files: urls
        )
        existingSubmissionID = submissionID
        submissionAssembly.start(fileSubmissionID: submissionID)
        return submissionID
    }
}

extension AttachmentSubmissionService: FileProgressListViewModelDelegate {

    public func fileProgressViewModelCancel(_ viewModel: FileProgressListViewModel) {
        if let existingSubmissionID = existingSubmissionID {
            submissionAssembly.cancel(submissionID: existingSubmissionID)
        }
        existingSubmissionID = nil
    }

    public func fileProgressViewModelRetry(_ viewModel: FileProgressListViewModel) {
        if let existingSubmissionID = existingSubmissionID {
            submissionAssembly.start(fileSubmissionID: existingSubmissionID)
        }
    }

    public func fileProgressViewModel(_ viewModel: FileProgressListViewModel, delete fileUploadItemID: NSManagedObjectID) {
        submissionAssembly.composer.deleteItem(itemID: fileUploadItemID)
    }

    public func fileProgressViewModel(_ viewModel: FileProgressListViewModel, didAcknowledgeSuccess fileSubmissionID: NSManagedObjectID) {
        submissionAssembly.markSubmissionAsDone(submissionID: fileSubmissionID)
    }
}
