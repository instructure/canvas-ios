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
    var env = AppEnvironment.shared
    let assignmentID: String
    var callback: (SubmissionComment?, Error?) -> Void = { _, _ in }
    let courseID: String
    let isGroup: Bool
    let batchID: String
    var files: UploadManager.Store?
    var placeholderID: String?
    let submissionID: String
    let userID: String
    var task: URLSessionTask?
    lazy var context = env.database.newBackgroundContext()
    var uploadContext: FileUploadContext {
        return .submissionComment(courseID: courseID, assignmentID: assignmentID)
    }

    private static var placeholderSuffix = 1

    public init(
        courseID: String,
        assignmentID: String,
        userID: String,
        submissionID: String,
        isGroup: Bool,
        batchID: String
    ) {
        self.assignmentID = assignmentID
        self.courseID = courseID
        self.isGroup = isGroup
        self.submissionID = submissionID
        self.userID = userID
        self.batchID = batchID
    }

    public func cancel() {
        task?.cancel()
        UploadManager.shared.cancel(batchID: batchID)
    }

    public func fetch(environment: AppEnvironment = .shared, _ callback: @escaping (SubmissionComment?, Error?) -> Void) {
        self.callback = callback
        self.env = environment
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
            placeholder.assignmentID = self.assignmentID
            placeholder.authorAvatarURL = session.userAvatarURL
            placeholder.authorID = session.userID
            placeholder.authorName = session.userName
            placeholder.comment = NSLocalizedString("See attached files.", bundle: .core, comment: "")
            placeholder.createdAt = Date()
            placeholder.id = "placeholder-\(UploadFileComment.placeholderSuffix)"
            placeholder.userID = self.userID
            do {
                try self.context.save()
                self.placeholderID = placeholder.id
                UploadFileComment.placeholderSuffix += 1
            } catch {
                self.callback(nil, error)
            }
        }
        UploadManager.shared.upload(batch: batchID, to: uploadContext)
    }

    func putComment(fileIDs: [String]) {
        let body = PutSubmissionGradeRequest.Body(comment: .init(fileIDs: fileIDs, forGroup: isGroup))
        task = env.api.makeRequest(PutSubmissionGradeRequest(courseID: courseID, assignmentID: assignmentID, userID: userID, body: body)) { data, _, error in
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
