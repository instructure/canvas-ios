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

    public init(api: API, context: NSManagedObjectContext) {
        self.api = api
        self.context = context
    }

    public func submitFiles(fileSubmissionID: NSManagedObjectID) -> AnyPublisher<APISubmission, FileSubmissionErrors.Submission> {
        return SubmissionPublishers
            .fetchDestinationBaseURL(fileSubmissionID: fileSubmissionID, api: api, context: context)
            .flatMap { baseURL in
                Future { [weak self] promise in
                    guard let self else { return promise(.failure(.submissionFailed)) }

                    sendRequest(
                        baseURL: baseURL,
                        fileSubmissionID: fileSubmissionID,
                        promise: promise
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    /** The result of the request is also written into the underlying `FileSubmission` object.  */
    private func sendRequest(
        baseURL: URL?,
        fileSubmissionID: NSManagedObjectID,
        promise: @escaping Future<APISubmission, FileSubmissionErrors.Submission>.Promise
    ) {
        context.performAndWait {
            guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else { return }
            let fileIDs = submission.files.compactMap { $0.apiID }
            let requestedSubmission = CreateSubmissionRequest.Body.Submission(
                text_comment: submission.comment,
                group_comment: submission.isGroupComment,
                submission_type: .online_upload,
                file_ids: fileIDs
            )
            let request = CreateSubmissionRequest(
                context: .course(submission.courseID),
                assignmentID: submission.assignmentID,
                body: .init(submission: requestedSubmission)
            )
            API(self.api.loginSession, baseURL: baseURL)
                .makeRequest(request) { [self] response, _, error in
                    handleResponse(response, error: error, fileSubmissionID: fileSubmissionID, promise: promise)
                }
        }
    }

    private func handleResponse(_ response: APISubmission?, error: Error?, fileSubmissionID: NSManagedObjectID, promise: @escaping Future<APISubmission, FileSubmissionErrors.Submission>.Promise) {
        context.perform { [self] in
            guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else {
                promise(.failure(.coreData(.submissionNotFound)))
                return
            }

            guard let response = response else {
                let validError: Error = error ?? NSError.instructureError(String(localized: "Submission failed due to unknown error.", bundle: .core))
                submission.submissionError = validError.localizedDescription
                submission.isSubmitted = false
                try? context.saveAndNotify()
                promise(.failure(.submissionFailed))
                return
            }

            submission.submissionError = nil
            submission.isSubmitted = true

            try? context.saveAndNotify()
            promise(.success(response))
        }
    }
}
