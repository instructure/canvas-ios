//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import CoreData

/**
 This class submits all the files with `apiID` to the assignment in the given `FileSubmission`.
 */
public class FileSubmissionSubmitter {
    private let api: API
    private let context: NSManagedObjectContext
    private let fileSubmissionID: NSManagedObjectID

    public init(api: API, context: NSManagedObjectContext, fileSubmissionID: NSManagedObjectID) {
        self.api = api
        self.context = context
        self.fileSubmissionID = fileSubmissionID
    }

    public func submitFiles() -> Future<Void, Error> {
        Future<Void, Error> { self.sendRequest($0) }
    }

    /** The result of the request is also written into the underlying `FileSubmission` object.  */
    private func sendRequest(_ promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [self] in
            guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else { return }
            let fileIDs = submission.files.compactMap { $0.apiID }
            let requestedSubmission = CreateSubmissionRequest.Body.Submission(text_comment: submission.comment,
                                                                     submission_type: .online_upload,
                                                                     file_ids: fileIDs)
            let request = CreateSubmissionRequest(context: .course(submission.courseID),
                                                      assignmentID: submission.assignmentID,
                                                      body: .init(submission: requestedSubmission))
            api.makeRequest(request) { [weak self] response, _, error in
                self?.handleResponse(response, error: error, promise: promise)
            }
        }
    }

    private func handleResponse(_ response: APISubmission?, error: Error?, promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [self] in
            guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else { return }

            if response == nil {
                let validError: Error = error ?? NSError.instructureError(NSLocalizedString("Submission failed due to unknown error.", comment: ""))
                submission.submissionError = validError.localizedDescription
                submission.isSubmitted = false
            } else {
                submission.submissionError = nil
                submission.isSubmitted = true
            }

            try? context.save()

            if let error = submission.submissionError {
                promise(.failure(error))
            } else {
                promise(.success(()))
            }
        }
    }
}
