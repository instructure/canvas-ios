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

public class CreateTextComment {
    let env: AppEnvironment
    let assignmentID: String
    var callback: (SubmissionComment?, Error?) -> Void = { _, _ in }
    let courseID: String
    let isGroup: Bool
    var placeholderID: String?
    let text: String
    let attempt: Int?
    let userID: String
    var task: APITask?

    private static var placeholderSuffix = 1

    public init(
        env: AppEnvironment,
        courseID: String,
        assignmentID: String,
        userID: String,
        isGroup: Bool,
        text: String,
        attempt: Int?
    ) {
        self.env = env
        self.assignmentID = assignmentID
        self.courseID = courseID
        self.isGroup = isGroup
        self.text = text
        self.attempt = attempt
        self.userID = userID
    }

    public func cancel() {
        task?.cancel()
    }

    public func fetch(_ callback: @escaping (SubmissionComment?, Error?) -> Void) {
        self.callback = callback
        savePlaceholder()
    }

    func savePlaceholder() {
        guard let session = env.currentSession else {
            return self.callback(nil, NSError.internalError()) // There should always be a current user.
        }
        env.database.performWriteTask { client in
            let placeholder: SubmissionComment = client.insert()
            placeholder.assignmentID = self.assignmentID
            placeholder.authorAvatarURL = session.userAvatarURL
            placeholder.authorID = session.userID
            placeholder.authorName = session.userName
            placeholder.comment = self.text
            placeholder.createdAt = Date()
            placeholder.id = "placeholder-\(CreateTextComment.placeholderSuffix)"
            placeholder.userID = self.userID
            if let attempt = self.attempt {
                placeholder.attemptFromAPI = NSNumber(value: attempt)
            }
            do {
                try client.save()
                self.placeholderID = placeholder.id
                CreateTextComment.placeholderSuffix += 1
                self.putComment()
            } catch {
                self.callback(nil, error)
            }
        }
    }

    func putComment() {
        let body = PutSubmissionGradeRequest.Body(comment: .init(text: text, forGroup: isGroup, attempt: attempt))
        task = env.api.makeRequest(PutSubmissionGradeRequest(courseID: courseID, assignmentID: assignmentID, userID: userID, body: body)) { data, _, error in
            self.task = nil
            guard error == nil, let submission = data, let comment = submission.submission_comments?.last else {
                return self.callback(nil, error)
            }
            self.env.database.performWriteTask { client in
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
