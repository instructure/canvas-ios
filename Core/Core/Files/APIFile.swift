//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/files.html#File
public struct APIFile: Codable, Equatable {
    let id: ID
    let uuid: String
    let folder_id: ID
    let display_name: String
    let filename: String
    let contentType: String
    let url: APIURL?
    // file size in bytes
    let size: Int
    let created_at: Date
    let updated_at: Date
    let unlock_at: Date?
    let locked: Bool
    let hidden: Bool
    let lock_at: Date?
    let hidden_for_user: Bool
    let thumbnail_url: APIURL?
    let modified_at: Date
    // simplified content-type mapping
    let mime_class: String
    // identifier for file in third-party transcoding service
    let media_entry_id: String?
    let locked_for_user: Bool
    // let lock_info: [String: Any]?
    let lock_explanation: String?
    // optional: url to the document preview. This url is specific to the user
    // making the api call. Only included in submission endpoints.
    let preview_url: APIURL?
    let avatar: APIFileToken?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case uuid = "uuid"
        case folder_id = "folder_id"
        case display_name = "display_name"
        case filename = "filename"
        case contentType = "content-type"
        case url = "url"
        case size = "size"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case unlock_at = "unlock_at"
        case locked = "locked"
        case hidden = "hidden"
        case lock_at = "lock_at"
        case hidden_for_user = "hidden_for_user"
        case thumbnail_url = "thumbnail_url"
        case modified_at = "modified_at"
        case mime_class = "mime_class"
        case media_entry_id = "media_entry_id"
        case locked_for_user = "locked_for_user"
        case lock_explanation = "lock_explanation"
        case preview_url = "preview_url"
        case avatar = "avatar"
    }

    init(
        id: ID,
        uuid: String,
        folder_id: ID,
        display_name: String,
        filename: String,
        contentType: String,
        url: APIURL,
        size: Int,
        created_at: Date,
        updated_at: Date,
        unlock_at: Date?,
        locked: Bool,
        hidden: Bool,
        lock_at: Date?,
        hidden_for_user: Bool,
        thumbnail_url: APIURL?,
        modified_at: Date,
        mime_class: String,
        media_entry_id: String?,
        locked_for_user: Bool,
        lock_explanation: String?,
        preview_url: APIURL?,
        avatar: APIFileToken?
    ) {
        self.id = id
        self.uuid = uuid
        self.folder_id = folder_id
        self.display_name = display_name
        self.filename = filename
        self.contentType = contentType
        self.url = url
        self.size = size
        self.created_at = created_at
        self.updated_at = updated_at
        self.unlock_at = unlock_at
        self.locked = locked
        self.hidden = hidden
        self.lock_at = lock_at
        self.hidden_for_user = hidden_for_user
        self.thumbnail_url = thumbnail_url
        self.modified_at = modified_at
        self.mime_class = mime_class
        self.media_entry_id = media_entry_id
        self.locked_for_user = locked_for_user
        self.lock_explanation = lock_explanation
        self.preview_url = preview_url
        self.avatar = avatar
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        uuid = try container.decode(String.self, forKey: .uuid)
        folder_id = try container.decode(ID.self, forKey: .folder_id)
        display_name = try container.decode(String.self, forKey: .display_name)
        filename = try container.decode(String.self, forKey: .filename)
        contentType = try container.decode(String.self, forKey: .contentType)
        let urlRaw = try container.decodeIfPresent(String.self, forKey: .url)
        if urlRaw == nil || urlRaw?.isEmpty == true {
            url = nil
        } else {
            url = try container.decode(APIURL.self, forKey: .url)
        }
        size = try container.decode(Int.self, forKey: .size)
        created_at = try container.decode(Date.self, forKey: .created_at)
        updated_at = try container.decode(Date.self, forKey: .updated_at)
        unlock_at = try container.decodeIfPresent(Date.self, forKey: .unlock_at)
        locked = try container.decode(Bool.self, forKey: .locked)
        hidden = try container.decode(Bool.self, forKey: .hidden)
        lock_at = try container.decodeIfPresent(Date.self, forKey: .lock_at)
        hidden_for_user = try container.decode(Bool.self, forKey: .hidden_for_user)
        thumbnail_url = try container.decodeIfPresent(APIURL.self, forKey: .thumbnail_url)
        modified_at = try container.decode(Date.self, forKey: .modified_at)
        mime_class = try container.decode(String.self, forKey: .mime_class)
        media_entry_id = try container.decodeIfPresent(String.self, forKey: .media_entry_id)
        locked_for_user = try container.decode(Bool.self, forKey: .locked_for_user)
        lock_explanation = try container.decodeIfPresent(String.self, forKey: .lock_explanation)
        preview_url = try container.decodeIfPresent(APIURL.self, forKey: .preview_url)
        avatar = try container.decodeIfPresent(APIFileToken.self, forKey: .avatar)
    }
}

public struct APIFileToken: Codable, Equatable {
    let token: String
}

// https://canvas.instructure.com/doc/api/files.html#Folder
public struct APIFileFolder: Codable, Equatable {
    let context_type: String
    let context_id: ID
    let files_count: Int
    let position: Int?
    let updated_at: Date
    let folders_url: APIURL
    let files_url: APIURL
    let full_name: String
    let lock_at: Date?
    let id: ID
    let folders_count: Int
    let name: String
    let parent_folder_id: ID?
    let created_at: Date
    let unlock_at: Date?
    let hidden: Bool?
    let hidden_for_user: Bool
    let locked: Bool
    let locked_for_user: Bool
    let for_submissions: Bool
}

// https://canvas.instructure.com/doc/api/files.html#method.files.api_show
public struct GetFileRequest: APIRequestable {
    public typealias Response = APIFile

    enum Include: String, Codable {
        case avatar, usage_rights, user
    }

    let context: Context?
    let fileID: String
    let include: [Include]

    public var path: String {
        if let context = context {
            return "\(context.pathComponent)/files/\(fileID)"
        } else {
            return "files/\(fileID)"
        }
    }

    public var query: [APIQueryItem] {
        return [ .include(include.map { $0.rawValue }) ]
    }
}

// https://canvas.instructure.com/doc/api/file.file_uploads.html - Step 1
public struct PostFileUploadTargetRequest: APIRequestable {
    public typealias Response = FileUploadTarget

    public struct Body: Codable, Equatable {
        let name: String
        let on_duplicate: OnDuplicate
        let parent_folder_id: String?
        let parent_folder_path: String?
        let size: Int

        public init(name: String, on_duplicate: OnDuplicate, parent_folder_id: String? = nil, parent_folder_path: String? = nil, size: Int) {
            self.name = name
            self.on_duplicate = on_duplicate
            self.parent_folder_id = parent_folder_id
            self.parent_folder_path = parent_folder_path
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
        var form: APIFormData = target.upload_params.map { (key, value) in
            (key: key, value: .string(value ?? ""))
        }
        form.append((key: "file", value: .file(
            filename: target.upload_params["filename"] as? String ?? "",
            type: target.upload_params["content_type"] as? String ?? "application/octet-stream",
            at: fileURL
        )))
        return form
    }
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.resolve_path
public class GetContextFolderHierarchyRequest: APIRequestable {
    public typealias Response = [APIFileFolder]

    let context: Context
    let fullPath: String

    init(context: Context, fullPath: String = "") {
        self.context = context
        self.fullPath = fullPath
    }

    public var path: String {
        "\(context.pathComponent)/folders/by_path/\(fullPath)"
    }

    public var query: [APIQueryItem] {
        [ .include([ "usage_rights" ]) ]
    }
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.api_index
public class ListFoldersRequest: APIRequestable {
    public typealias Response = [APIFileFolder]

    let context: Context
    let perPage: Int?

    init(context: Context, perPage: Int? = 100) {
        self.context = context
        self.perPage = perPage
    }

    public var path: String {
        "\(context.pathComponent)/folders"
    }

    public var query: [APIQueryItem] {
        [
            .include([ "usage_rights" ]),
            .perPage(perPage),
        ]
    }
}

// https://canvas.instructure.com/doc/api/files.html#method.files.api_index
public class ListFilesRequest: APIRequestable {
    public typealias Response = [APIFile]

    let context: Context
    let perPage: Int?

    init(context: Context, perPage: Int? = 100) {
        self.context = context
        self.perPage = perPage
    }

    public var path: String {
        "\(context.pathComponent)/files"
    }

    public var query: [APIQueryItem] {
        [
            .include([ "usage_rights" ]),
            .perPage(perPage),
        ]
    }
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.show
public class GetFolderRequest: APIRequestable {
    public typealias Response = APIFileFolder

    let context: Context?
    let id: ID

    init(context: Context?, id: ID) {
        self.context = context
        self.id = id
    }

    public var path: String {
        if let context = context {
            return "\(context.pathComponent)/folders/\(id)"
        } else {
            return "folders/\(id)"
        }
    }

    public var query: [APIQueryItem] {
        [ .include([ "usage_rights" ]) ]
    }
}

// https://canvas.instructure.com/doc/api/files.html#method.files.destroy
struct DeleteFileRequest: APIRequestable {
    typealias Response = APIFile

    let fileID: String

    let method = APIMethod.delete
    var path: String { "files/\(fileID)" }
}
