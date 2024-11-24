//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class UploadFileComment {
    let env = AppEnvironment.shared
    let destination: SubmissionDestination
    var callback: (SubmissionComment?, Error?) -> Void = { _, _ in }
    let isGroup: Bool
    let batchID: String
    var files: UploadManager.Store?
    var placeholderID: String?
    let attempt: Int?
    var task: APITask?
    lazy var context = env.database.newBackgroundContext()

    var uploadContext: FileUploadContext {
        return .submissionComment(
            courseID: destination.courseID,
            assignmentID: destination.assignmentID,
            userID: destination.userID
        )
    }

    var apiCoordinator: SubmissionApiCoordinator = DefaultSubmissionApiCoordinator()

    private static var placeholderSuffix = 1

    public init(
        destination: SubmissionDestination,
        isGroup: Bool,
        batchID: String,
        attempt: Int?
    ) {
        self.destination = destination
        self.isGroup = isGroup
        self.batchID = batchID
        self.attempt = attempt
    }

    public func cancel() {
        task?.cancel()
        UploadManager.shared.cancel(batchID: batchID)
    }

    public func fetch(_ callback: @escaping (SubmissionComment?, Error?) -> Void) {
        self.callback = callback
        files = UploadManager.shared.subscribe(batchID: batchID) {
            guard let files = self.files, !files.isEmpty else { return }
            if files.allSatisfy({ $0.isUploaded }) == true {
                let fileIDs = files.compactMap { $0.id }
                self.putComment(fileIDs: fileIDs)
                self.files = nil
                return
            }

            if let error = files.compactMap({ $0.uploadError }).first {
                callback(nil, NSError.instructureError(error))
                self.files = nil
                return
            }
        }
        savePlaceholder()
    }

    func savePlaceholder() {
        guard let session = env.currentSession else {
            return self.callback(nil, NSError.internalError()) // There should always be a current user.
        }
        context.performAndWait {
            let placeholder: SubmissionComment = self.context.insert()
            placeholder.assignmentID = self.destination.assignmentID
            placeholder.authorAvatarURL = session.userAvatarURL
            placeholder.authorID = session.userID
            placeholder.authorName = session.userName
            placeholder.comment = String(localized: "See attached files.", bundle: .core)
            placeholder.createdAt = Date()
            placeholder.id = "placeholder-\(UploadFileComment.placeholderSuffix)"
            placeholder.userID = self.destination.userID
            if let attempt = self.attempt {
                placeholder.attemptFromAPI = NSNumber(value: attempt)
            }
            do {
                try self.context.save()
                self.placeholderID = placeholder.id
                UploadFileComment.placeholderSuffix += 1
            } catch {
                self.callback(nil, error)
            }
        }
        UploadManager.shared.upload(batch: batchID, to: uploadContext, baseURL: destination.baseURL(in: env))
    }

    func putComment(fileIDs: [String]) {
        let body = PutSubmissionGradeRequest.Body(comment: .init(fileIDs: fileIDs, forGroup: isGroup, attempt: attempt))
        let request = PutSubmissionGradeRequest(
            courseID: destination.courseID,
            assignmentID: destination.assignmentID,
            userID: destination.userID,
            body: body
        )

        task = apiCoordinator
            .api(for: destination, in: env)
            .makeRequest(request) { data, _, error in
                self.task = nil
                guard error == nil, let submission = data, let comment = submission.submission_comments?.last else {
                    return self.callback(nil, error)
                }
                self.context.performAndWait {
                    let comment = SubmissionComment.save(comment, for: submission, replacing: self.placeholderID, in: self.context)
                    var e: Error?
                    defer { self.callback(comment, e) }
                    do {
                        try self.context.save()
                    } catch {
                        e = error
                    }
                }
            }
    }
}
