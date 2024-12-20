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
 This class iterates through a `FileSubmission`'s `FileUploadItem`s and starts their binary upload.
 The created `URLSessionTask`'s `taskDescription` field will contain the `FileUploadItem`s
 `objectID` so when we receive progress updates we know which `URLSessionTask` is for which `FileUploadItem`.
 */
public class FileSubmissionItemsUploadStarter {
    private let api: API
    private let context: NSManagedObjectContext
    private let backgroundSessionProvider: BackgroundURLSessionProvider

    public init(api: API, context: NSManagedObjectContext, backgroundSessionProvider: BackgroundURLSessionProvider) {
        self.api = api
        self.context = context
        self.backgroundSessionProvider = backgroundSessionProvider
    }

    /**
     - returns: A `Future` that finishes when all available files for upload have started their uploading. Fails if the submission doesn't exist.
     */
    public func startUploads(fileSubmissionID: NSManagedObjectID) -> Future<Void, Error> {
        Future<Void, Error> { self.uploadFiles(fileSubmissionID: fileSubmissionID, promise: $0) }
    }

    private func uploadFiles(fileSubmissionID: NSManagedObjectID, promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [self] in
            guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else {
                promise(.failure(FileSubmissionErrors.CoreData.submissionNotFound))
                return
            }

            for file in submission.files {
                guard let uploadTarget = file.uploadTarget else {
                    file.uploadError = String(localized: "Failed to start upload.", bundle: .core)
                    continue
                }

                file.apiID = nil
                file.uploadError = nil
                file.bytesUploaded = 0

                let request = PostFileUploadRequest(fileURL: file.localFileURL, target: uploadTarget)
                let api = API(baseURL: uploadTarget.upload_url, urlSession: backgroundSessionProvider.session)

                do {
                    var task = try api.uploadTask(request)
                    task.taskID = file.objectID.uriRepresentation().absoluteString
                    task.resume()
                } catch {
                    file.uploadError = String(localized: "Failed to start upload.", bundle: .core)
                }
            }

            // We want to disconnect from the session and tear it down after all uploads complete
            backgroundSessionProvider.session.finishTasksAndInvalidate()
            try? context.saveAndNotify()
            promise(.success(()))
        }
    }
}
