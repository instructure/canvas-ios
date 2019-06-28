//
// Copyright (C) 2018-present Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/files.html#method.files.api_show
public struct GetFileRequest: APIRequestable {
    public typealias Response = APIFile

    let context: Context
    let fileID: String

    public var path: String {
        return "\(context.pathComponent)/files/\(fileID)"
    }
}

// https://canvas.instructure.com/doc/api/file.file_uploads.html - Step 1
public struct PostFileUploadTargetRequest: APIRequestable {
    public typealias Response = FileUploadTarget

    public struct Body: Codable, Equatable {
        let name: String
        let on_duplicate: OnDuplicate
        let parent_folder_id: String?
        let size: Int

        public init(name: String, on_duplicate: OnDuplicate, parent_folder_id: String?, size: Int) {
            self.name = name
            self.on_duplicate = on_duplicate
            self.parent_folder_id = parent_folder_id
            self.size = size
        }
    }

    public enum OnDuplicate: String, Codable {
        case rename, overwrite
    }

    public let context: FileUploadContext
    public let body: Body?
    public let method: APIMethod = .post

    public var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    public var path: String {
        switch context {
        case let .course(courseID):
            let context = ContextModel(.course, id: courseID)
            return "\(context.pathComponent)/files"
        case let .user(userID):
            let context = ContextModel(.user, id: userID)
            return "\(context.pathComponent)/files"
        case let .submission(courseID, assignmentID, _):
            let context = ContextModel(.course, id: courseID)
            return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/self/files"
        case let .submissionComment(courseID, assignmentID):
            let context = ContextModel(.course, id: courseID)
            return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/self/comments/files"
        }
    }

    public init(context: FileUploadContext, body: Body) {
        self.context = context
        self.body = body
    }
}

// https://canvas.instructure.com/doc/api/file.file_uploads.html - Step 2
public struct PostFileUploadRequest: APIRequestable {
    public typealias Response = APIFile

    public let fileURL: URL
    public let target: FileUploadTarget

    public init(fileURL: URL, target: FileUploadTarget) {
        self.fileURL = fileURL
        self.target = target
    }

    public let cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    public let method = APIMethod.post
    public let headers: [String: String?] = [
        HttpHeader.authorization: nil,
    ]
    public var path: String {
        return target.upload_url.absoluteString
    }
    public var form: APIFormData? {
        var form: APIFormData = target.upload_params.mapValues { APIFormDatum.string($0) }
        form["file"] = .file(
            filename: target.upload_params["filename"] ?? "",
            type: target.upload_params["content_type"] ?? "application/octet-stream",
            at: fileURL
        )
        return form
    }
}
