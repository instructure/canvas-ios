//
// Copyright (C) 2019-present Instructure, Inc.
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

public class UploadFileComment {
    var env = AppEnvironment.shared
    let assignmentID: String
    var callback: (SubmissionComment?, Error?) -> Void = { _, _ in }
    let courseID: String
    let isGroup: Bool
    let batchID: String
    lazy var uploadBatch = UploadBatch(environment: env, batchID: batchID, callback: nil)
    var placeholderID: String?
    let submissionID: String
    let userID: String
    var task: URLSessionTask?

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
        uploadBatch.cancel()
    }

    public func fetch(environment: AppEnvironment = .shared, _ callback: @escaping (SubmissionComment?, Error?) -> Void) {
        self.callback = callback
        self.env = environment
        savePlaceholder()
    }

    func savePlaceholder() {
        guard let session = env.currentSession else {
            return self.callback(nil, NSError.internalError()) // There should always be a current user.
        }
        env.database.performBackgroundTask { client in
            let placeholder: SubmissionComment = client.insert()
            placeholder.authorAvatarURL = session.userAvatarURL
            placeholder.authorID = session.userID
            placeholder.authorName = session.userName
            placeholder.comment = NSLocalizedString("See attached files.", bundle: .core, comment: "")
            placeholder.createdAt = Date()
            placeholder.id = "placeholder-\(UploadFileComment.placeholderSuffix)"
            placeholder.submissionID = self.submissionID
            do {
                try client.save()
                self.placeholderID = placeholder.id
                UploadFileComment.placeholderSuffix += 1
                let context = FileUploadContext.submissionComment(courseID: self.courseID, assignmentID: self.assignmentID)
                self.uploadBatch.upload(to: context) { state in
                    switch state {
                    case .staged?, .uploading?, nil: break
                    case let .completed(fileIDs: fileIDs)?:
                        self.putComment(fileIDs: Array(fileIDs))
                    case .failed(let error)?:
                        self.callback(nil, error)
                    }
                }
            } catch {
                self.callback(nil, error)
            }
        }
    }

    func putComment(fileIDs: [String]) {
        let body = PutSubmissionGradeRequest.Body(comment: .init(fileIDs: fileIDs, forGroup: isGroup), submission: nil)
        task = env.api.makeRequest(PutSubmissionGradeRequest(courseID: courseID, assignmentID: assignmentID, userID: userID, body: body)) { data, _, error in
            self.task = nil
            guard error == nil, let comment = data?.submission_comments?.last else {
                return self.callback(nil, error)
            }
            self.env.database.performBackgroundTask { client in
                let comment = SubmissionComment.save(comment, forSubmission: self.submissionID, replacing: self.placeholderID, in: client)
                var e: Error?
                defer { self.callback(comment, e) }
                do {
                    try client.save()
                } catch {
                    e = error
                }
            }
        }
    }
}
