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

        public init(name: String, on_duplicate: OnDuplicate, parent_folder_id: String?) {
            self.name = name
            self.on_duplicate = on_duplicate
            self.parent_folder_id = parent_folder_id
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
        case let .submission(courseID, assignmentID):
            let context = ContextModel(.course, id: courseID)
            return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/self/files"
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
    public let boundary = UUID.string

    public var body: URL? {
        return fileURL
    }

    public init(fileURL: URL, target: FileUploadTarget) {
        self.fileURL = fileURL
        self.target = target
    }

    public let method: APIMethod = .post
    public var path: String {
        return target.upload_url.absoluteString
    }
    public var headers: [String: String?] {
        let multipart = "multipart/form-data; charset=utf-8; boundary=\"\(boundary)\""
        return [
            HttpHeader.authorization: nil,
            HttpHeader.contentType: multipart,
        ]
    }
    public var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    public func encode(_ body: URL) throws -> Data {
        let delim = "--\(boundary)\r\n".data(using: .utf8)!
        let params = target.upload_params

        let file = try Data(contentsOf: body)
        var body = Data()
        body += delim

        // First append each key/value in upload_params
        for (key, value) in params {
            body += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n".data(using: .utf8)!
            body += delim
        }

        // File must be appended last
        let filename = params["filename"] ?? ""
        body += "Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n\r\n".data(using: .utf8)!
        body += file
        body += "\r\n--\(boundary)--\r\n".data(using: .utf8)!

        return body
    }
}
