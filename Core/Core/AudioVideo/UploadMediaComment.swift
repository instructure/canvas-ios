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

public class UploadMediaComment {
    var env = AppEnvironment.shared
    let assignmentID: String
    var callback: (SubmissionComment?, Error?) -> Void = { _, _ in }
    let courseID: String
    let isGroup: Bool
    var placeholderID: String?
    let submissionID: String
    let type: MediaCommentType
    let url: URL
    let uploader: UploadMedia
    let userID: String
    var task: URLSessionTask?

    private static var placeholderSuffix = 1

    public init(
        courseID: String,
        assignmentID: String,
        userID: String,
        submissionID: String,
        isGroup: Bool,
        type: MediaCommentType,
        url: URL
    ) {
        self.assignmentID = assignmentID
        self.courseID = courseID
        self.isGroup = isGroup
        self.submissionID = submissionID
        self.type = type
        self.url = url
        self.uploader = UploadMedia(type: type, url: url)
        self.userID = userID
    }

    public func cancel() {
        task?.cancel()
        uploader.cancel()
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
            placeholder.assignmentID = self.assignmentID
            placeholder.authorAvatarURL = session.userAvatarURL
            placeholder.authorID = session.userID
            placeholder.authorName = session.userName
            placeholder.comment = ""
            placeholder.createdAt = Date()
            placeholder.id = "placeholder-\(UploadMediaComment.placeholderSuffix)"
            placeholder.mediaID = "_"
            placeholder.mediaType = self.type
            placeholder.mediaURL = self.url
            placeholder.userID = self.userID
            do {
                try client.save()
                self.placeholderID = placeholder.id
                UploadMediaComment.placeholderSuffix += 1
                self.uploader.fetch(environment: self.env) { mediaID, error in
                    guard error == nil, let mediaID = mediaID else {
                        self.callback(nil, error)
                        return
                    }
                    self.putComment(mediaID: mediaID)
                }
            } catch {
                self.callback(nil, error)
            }
        }
    }

    func putComment(mediaID: String) {
        let body = PutSubmissionGradeRequest.Body(comment: .init(mediaID: mediaID, type: type, forGroup: isGroup))
        task = env.api.makeRequest(PutSubmissionGradeRequest(courseID: courseID, assignmentID: assignmentID, userID: userID, body: body)) { data, _, error in
            self.task = nil
            guard error == nil, let submission = data, let comment = submission.submission_comments?.last else {
                return self.callback(nil, error)
            }
            self.env.database.performBackgroundTask { client in
                let comment = SubmissionComment.save(comment, for: submission, replacing: self.placeholderID, in: client)
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
