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

public class UploadMediaComment {
    var env = AppEnvironment.shared
    let assignmentID: String
    var callback: (SubmissionComment?, Error?) -> Void = { _, _ in }
    let courseID: String
    let isGroup: Bool
    var mediaAPI: API?
    let submissionID: String
    let type: MediaCommentType
    let url: URL
    let userID: String
    var task: URLSessionTask?

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
        self.userID = userID
    }

    public func cancel() {
        task?.cancel()
    }

    public func fetch(environment: AppEnvironment = .shared, _ callback: @escaping (SubmissionComment?, Error?) -> Void) {
        self.callback = callback
        self.env = environment
        upload()
    }

    public func upload() {
        task = env.api.makeRequest(GetMediaServiceRequest()) { (data, _, error) in
            guard
                error == nil,
                let domain = data?.domain.replacingOccurrences(of: "https://", with: ""),
                let url = URL(string: "https://\(domain)")
            else {
                return self.callback(nil, error)
            }
            self.mediaAPI = URLSessionAPI(accessToken: nil, baseURL: url)
            self.getSession()
        }
    }

    func getSession() {
        task = env.api.makeRequest(PostMediaSessionRequest()) { (data, _, error) in
            guard error == nil, let ks = data?.ks else {
                return self.callback(nil, error)
            }
            self.getUploadToken(ks: ks)
        }
    }

    func getUploadToken(ks: String) {
        task = mediaAPI?.makeRequest(PostMediaUploadTokenRequest(body: .init(ks: ks))) { (data, _, error) in
            guard error == nil, let token = data?.id, !token.isEmpty else {
                return self.callback(nil, error)
            }
            self.postUpload(ks: ks, token: token)
        }
    }

    func postUpload(ks: String, token: String) {
        task = mediaAPI?.makeRequest(PostMediaUploadRequest(fileURL: url, type: type, ks: ks, token: token)) { (_, _, error) in
            guard error == nil else {
                return self.callback(nil, error)
            }
            self.getMediaID(ks: ks, token: token)
        }
    }

    func getMediaID(ks: String, token: String) {
        task = mediaAPI?.makeRequest(PostMediaIDRequest(ks: ks, token: token, type: type)) { (data, _, error) in
            guard error == nil, let mediaID = data?.id, !mediaID.isEmpty else {
                return self.callback(nil, error)
            }
            self.putComment(mediaID: mediaID)
        }
    }

    func putComment(mediaID: String) {
        let body = PutSubmissionGradeRequest.Body(comment: .init(mediaID: mediaID, type: type, forGroup: isGroup), submission: nil)
        task = env.api.makeRequest(PutSubmissionGradeRequest(courseID: courseID, assignmentID: assignmentID, userID: userID, body: body)) { data, _, error in
            self.task = nil
            guard error == nil, let comment = data?.submission_comments?.last else {
                return self.callback(nil, error)
            }
            self.env.database.performBackgroundTask { client in
                let comment = SubmissionComment.save(comment, forSubmission: self.submissionID, in: client)
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
