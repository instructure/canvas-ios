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
 This class iterates through a `FileSubmission`'s `FileUploadItem`s and starts getting file upload target for them.
 */
public class FileSubmissionTargetsRequester {
    private let api: API
    private let context: NSManagedObjectContext

    public init(api: API, context: NSManagedObjectContext) {
        self.api = api
        self.context = context
    }

    public func request(fileSubmissionID: NSManagedObjectID) -> AnyPublisher<Void, Error> {
        return SubmissionPublishers
            .fetchDestinationBaseURL(fileSubmissionID: fileSubmissionID, api: api, context: context)
            .flatMap { baseURL in
                Future { [weak self] promise in

                    guard let self else {
                        return promise(.failure(FileSubmissionErrors.Submission.submissionFailed))
                    }

                    requestFileUploadTargets(
                        baseURL: baseURL,
                        fileSubmissionID: fileSubmissionID,
                        promise: promise
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    private func requestFileUploadTargets(baseURL: URL?, fileSubmissionID: NSManagedObjectID, promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [api, context] in
            guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else {
                promise(.failure(FileSubmissionErrors.CoreData.submissionNotFound))
                return
            }

            let targetRequests = submission
                .files
                .map {
                    FileUploadTargetRequester(api: api, context: context, fileUploadItemID: $0.objectID)
                        .requestUploadTarget(baseURL: baseURL)
                }

            var targetRequestsSubmission: AnyCancellable?
            targetRequestsSubmission = targetRequests
                .allFinished()
                .sink { completion in
                    switch completion {
                    case .finished:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                    targetRequestsSubmission?.cancel()
                    targetRequestsSubmission = nil
                }
        }
    }
}
