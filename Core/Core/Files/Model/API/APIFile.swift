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

// https://canvas.instructure.com/doc/api/files.html#filePath
public struct APIFile: Codable, Equatable {
    let id: ID
    let uuid: String
    let folder_id: ID
    let display_name: String
    let filename: String
    let contentType: String
    var url: APIURL?
    // file size in bytes
    let size: Int?
    let created_at: Date
    let updated_at: Date
    let unlock_at: Date?
    let locked: Bool
    var hidden: Bool
    let lock_at: Date?
    let hidden_for_user: Bool
    var thumbnail_url: APIURL?
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
    var preview_url: APIURL?
    let avatar: APIFileToken?
    var usage_rights: APIUsageRights?

    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case folder_id
        case display_name
        case filename
        case contentType = "content-type"
        case url
        case size
        case created_at
        case updated_at
        case unlock_at
        case locked
        case hidden
        case lock_at
        case hidden_for_user
        case thumbnail_url
        case modified_at
        case mime_class
        case media_entry_id
        case locked_for_user
        case lock_explanation
        case preview_url
        case avatar
        case usage_rights
    }

    init(
        id: ID,
        uuid: String,
        folder_id: ID,
        display_name: String,
        filename: String,
        contentType: String,
        url: APIURL,
        size: Int?,
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
        avatar: APIFileToken?,
        usage_rights: APIUsageRights?
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
        self.usage_rights = usage_rights
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        uuid = try container.decode(String.self, forKey: .uuid)
        folder_id = try container.decode(ID.self, forKey: .folder_id)
        display_name = try container.decode(String.self, forKey: .display_name)
        filename = try container.decode(String.self, forKey: .filename)
        contentType = try container.decode(String.self, forKey: .contentType)
        url = try container.decodeURLIfPresent(forKey: .url)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
        created_at = try container.decode(Date.self, forKey: .created_at)
        updated_at = try container.decode(Date.self, forKey: .updated_at)
        unlock_at = try container.decodeIfPresent(Date.self, forKey: .unlock_at)
        locked = try container.decode(Bool.self, forKey: .locked)
        hidden = try container.decode(Bool.self, forKey: .hidden)
        lock_at = try container.decodeIfPresent(Date.self, forKey: .lock_at)
        hidden_for_user = try container.decode(Bool.self, forKey: .hidden_for_user)
        thumbnail_url = try container.decodeURLIfPresent(forKey: .thumbnail_url)
        modified_at = try container.decode(Date.self, forKey: .modified_at)
        mime_class = try container.decode(String.self, forKey: .mime_class)
        media_entry_id = try container.decodeIfPresent(String.self, forKey: .media_entry_id)
        locked_for_user = try container.decode(Bool.self, forKey: .locked_for_user)
        lock_explanation = try container.decodeIfPresent(String.self, forKey: .lock_explanation)
        preview_url = try container.decodeURLIfPresent(forKey: .preview_url)
        avatar = try container.decodeIfPresent(APIFileToken.self, forKey: .avatar)
        usage_rights = try container.decodeIfPresent(APIUsageRights.self, forKey: .usage_rights)
    }
}

public struct APIFileToken: Codable, Equatable {
    let token: String
}

// https://canvas.instructure.com/doc/api/files.html#Folder
public struct APIFolder: Codable, Equatable {
    let can_upload: Bool
    let context_type: String
    let context_id: ID
    let files_count: Int
    let position: Int?
    let updated_at: Date
    let folders_url: APIURL
    let files_url: APIURL
    let full_name: String
    let lock_at: Date?
    public let id: ID
    let folders_count: Int
    var name: String
    let parent_folder_id: ID?
    let created_at: Date
    let unlock_at: Date?
    let hidden: Bool?
    let hidden_for_user: Bool
    let locked: Bool
    let locked_for_user: Bool
    let for_submissions: Bool
}

// https://canvas.instructure.com/doc/api/files.html#UsageRights
public struct APIUsageRights: Codable, Equatable {
    public let legal_copyright: String?
    public let license: String?
    public let use_justification: UseJustification?
}

public enum APIFolderItem: Codable {
    case file(APIFile)
    case folder(APIFolder)

    public init(from decoder: Decoder) throws {
        throw NSError.instructureError("Not for actual api decoding")
    }

    public func encode(to encoder: Encoder) throws {
        throw NSError.instructureError("Not for actual api encoding")
    }
}

#if DEBUG
public extension APIFile {
    static func make(
        id: ID = "1",
        uuid: String = "uuid-1234",
        folder_id: ID = "1",
        display_name: String = "File",
        filename: String = "File.jpg",
        contentType: String = "image/jpeg",
        url: URL = URL(string: "https://canvas.instructure.com/files/1/download")!,
        size: Int = 1024,
        created_at: Date = Date(),
        updated_at: Date = Date(),
        unlock_at: Date? = nil,
        locked: Bool = false,
        hidden: Bool = false,
        lock_at: Date? = nil,
        hidden_for_user: Bool = false,
        thumbnail_url: URL? = nil,
        modified_at: Date = Date(),
        mime_class: String = "image",
        media_entry_id: String? = nil,
        locked_for_user: Bool = false,
        lock_explanation: String? = nil,
        preview_url: URL? = nil,
        avatar: APIFileToken? = nil,
        usage_rights: APIUsageRights? = nil
    ) -> APIFile {
        return APIFile(
            id: id,
            uuid: uuid,
            folder_id: folder_id,
            display_name: display_name,
            filename: filename,
            contentType: contentType,
            url: APIURL(rawValue: url),
            size: size,
            created_at: created_at,
            updated_at: updated_at,
            unlock_at: unlock_at,
            locked: locked,
            hidden: hidden,
            lock_at: lock_at,
            hidden_for_user: hidden_for_user,
            thumbnail_url: APIURL(rawValue: thumbnail_url),
            modified_at: modified_at,
            mime_class: mime_class,
            media_entry_id: media_entry_id,
            locked_for_user: locked_for_user,
            lock_explanation: lock_explanation,
            preview_url: APIURL(rawValue: preview_url),
            avatar: avatar,
            usage_rights: usage_rights
        )
    }
}

public extension APIFolder {
    static func make(
        can_upload: Bool = true,
        context_type: String = "User",
        context_id: ID = 1,
        files_count: Int = 1,
        position: Int? = nil,
        updated_at: Date = Date(),
        folders_url: URL = URL(string: "https://canvas.instructure.com/api/v1/folders/1/folders")!,
        files_url: URL = URL(string: "https://canvas.instructure.com/api/v1/folders/1/files")!,
        full_name: String = "my files",
        lock_at: Date? = nil,
        id: ID = 1,
        folders_count: Int = 1,
        name: String = "my files",
        parent_folder_id: ID? = nil,
        created_at: Date = Date(),
        unlock_at: Date? = nil,
        hidden: Bool? = nil,
        hidden_for_user: Bool = false,
        locked: Bool = false,
        locked_for_user: Bool = false,
        for_submissions: Bool = false
    ) -> APIFolder {
        APIFolder(
            can_upload: can_upload,
            context_type: context_type,
            context_id: context_id,
            files_count: files_count,
            position: position,
            updated_at: updated_at,
            folders_url: APIURL(rawValue: folders_url),
            files_url: APIURL(rawValue: files_url),
            full_name: full_name,
            lock_at: lock_at,
            id: id,
            folders_count: folders_count,
            name: name,
            parent_folder_id: parent_folder_id,
            created_at: created_at,
            unlock_at: unlock_at,
            hidden: hidden,
            hidden_for_user: hidden_for_user,
            locked: locked,
            locked_for_user: locked_for_user,
            for_submissions: for_submissions
        )
    }
}

public extension APIUsageRights {
    static func make(
        legal_copyright: String? = nil,
        license: String? = nil,
        use_justification: UseJustification? = nil
    ) -> APIUsageRights {
        return APIUsageRights(
            legal_copyright: legal_copyright,
            license: license,
            use_justification: use_justification
        )
    }
}
#endif

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
        return [.include(include.map { $0.rawValue })]
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
        case let .context(context):
            return "\(context.pathComponent)/files"
        case let .submission(courseID, assignmentID, _):
            let context = Context(.course, id: courseID)
            return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/self/files"
        case let .submissionComment(courseID, assignmentID, userID):
            let context = Context(.course, id: courseID)
            return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/\(userID)/comments/files"
        }
    }

    public init(context: FileUploadContext, body: Body?) {
        self.context = context
        self.body = body
    }
}

// https://canvas.instructure.com/doc/api/file.file_uploads.html - Step 2
public struct PostFileUploadRequest: APIRequestable {
    public typealias Response = APIFile

    public let fileURL: URL
    public let target: FileUploadTarget
    public let loadBodyFromURL: Bool

    /**
         Creates an `APIRequestable` instance for file upload.
         - Parameters:
             - fileURL: The `URL` at which the file is located.
             - target: `FileUploadTarget` for upload parameters
             - isBodyFromURL: By default it's set to **true** meaning that the request will try to read the data from a file. See `APIRequestable` for more details.
     */
    public init(
        fileURL: URL,
        target: FileUploadTarget,
        isBodyFromURL: Bool = true
    ) {
        self.fileURL = fileURL
        self.target = target
        loadBodyFromURL = isBodyFromURL
    }

    public let cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    public let method = APIMethod.post
    public var path: String {
        return target.upload_url.absoluteString
    }

    public var form: APIFormData? {
        var form: APIFormData = target.upload_params.map { key, value in
            (key: key, value: .string(value ?? ""))
        }
        let filename = target.upload_params["filename"] ?? target.upload_params["Filename"]
        form.append((key: "file", value: .file(
            filename: filename as? String ?? "",
            type: target.upload_params["content_type"] as? String ?? "application/octet-stream",
            at: fileURL
        )))
        return form
    }

    public var isBodyFromURL: Bool { loadBodyFromURL }
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.resolve_path
public class GetContextFolderHierarchyRequest: APIRequestable {
    public typealias Response = [APIFolder]

    let context: Context
    let fullPath: String

    init(context: Context, fullPath: String = "") {
        self.context = context
        self.fullPath = fullPath
    }

    public var path: String {
        "\(context.pathComponent)/folders/by_path/\(fullPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
    }

    public var query: [APIQueryItem] {
        [.include(["usage_rights"])]
    }
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.api_index
public class GetFoldersRequest: APIRequestable {
    public typealias Response = [APIFolder]

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
            .include(["usage_rights"]),
            .perPage(perPage),
        ]
    }
}

// https://canvas.instructure.com/doc/api/files.html#method.files.api_index
public class GetFilesRequest: APIRequestable {
    public typealias Response = [APIFile]

    let context: Context
    let searchTerm: String?
    let perPage: Int?

    init(context: Context, searchTerm: String? = nil, perPage: Int? = 100) {
        self.context = context
        self.searchTerm = searchTerm
        self.perPage = perPage
    }

    public var path: String { "\(context.pathComponent)/files" }

    public var query: [APIQueryItem] { [
        .include(["usage_rights"]),
        .optionalValue("search_term", searchTerm),
        .perPage(perPage),
    ] }
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.show
public class GetFolderRequest: APIRequestable {
    public typealias Response = APIFolder

    let context: Context?
    let id: String

    init(context: Context?, id: String) {
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
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.create
struct PostFolderRequest: APIRequestable {
    typealias Response = APIFolder

    struct Body: Codable {
        let name: String
        let parent_folder_id: String
        let locked: Bool
    }

    let context: Context
    let body: Body?

    init(context: Context, name: String, parentFolderID: String) {
        self.context = context
        body = Body(name: name, parent_folder_id: parentFolderID, locked: true)
    }

    var method: APIMethod { .post }
    var path: String { "\(context.pathComponent)/folders" }
}

// https://canvas.instructure.com/doc/api/files.html#method.files.api_update
struct PutFileRequest: APIRequestable {
    typealias Response = APIFile
    struct Body: Codable {
        let name: String
        let locked: Bool
        let hidden: Bool
        let unlock_at: Date?
        let lock_at: Date?

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(locked, forKey: .locked)
            try container.encode(hidden, forKey: .hidden)
            // Auto-generated code omits the nil value properties.
            // These need to be present and null to remove previous values.
            try container.encode(unlock_at, forKey: .unlock_at)
            try container.encode(lock_at, forKey: .lock_at)
        }
    }

    let fileID: String
    let body: Body?

    init(fileID: String, name: String, locked: Bool, hidden: Bool, unlockAt: Date?, lockAt: Date?) {
        self.fileID = fileID
        body = Body(name: name, locked: locked, hidden: hidden, unlock_at: unlockAt, lock_at: lockAt)
    }

    var method: APIMethod { .put }
    var path: String { "files/\(fileID)" }
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.update
struct PutFolderRequest: APIRequestable {
    typealias Response = APIFolder
    typealias Body = PutFileRequest.Body

    let folderID: String
    let body: Body?

    init(folderID: String, name: String, locked: Bool, hidden: Bool, unlockAt: Date?, lockAt: Date?) {
        self.folderID = folderID
        body = Body(name: name, locked: locked, hidden: hidden, unlock_at: unlockAt, lock_at: lockAt)
    }

    var method: APIMethod { .put }
    var path: String { "folders/\(folderID)" }
}

// https://canvas.instructure.com/doc/api/files.html#method.files.destroy
struct DeleteFileRequest: APIRequestable {
    typealias Response = APIFile

    let fileID: String

    var method: APIMethod { .delete }
    var path: String { "files/\(fileID)" }
}

// https://canvas.instructure.com/doc/api/files.html#method.folders.api_destroy
struct DeleteFolderRequest: APIRequestable {
    typealias Response = APIFolder

    let folderID: String
    let force: Bool

    var method: APIMethod { .delete }
    var path: String { "folders/\(folderID)" }
    var query: [APIQueryItem] { [.bool("force", force)] }
}

// https://canvas.instructure.com/doc/api/files.html#method.usage_rights.set_usage_right
public struct PutUsageRightsRequest: APIRequestable {
    public struct Body: Codable {
        let file_ids: [String]
        let publish: Bool?
        let usage_rights: APIUsageRights
    }

    public typealias Response = APIUsageRights

    public let context: Context
    public let body: Body?

    public init(context: Context, fileIDs: [String], publish: Bool? = nil, usageRights: APIUsageRights) {
        self.context = context
        body = Body(file_ids: fileIDs, publish: publish, usage_rights: usageRights)
    }

    public var method: APIMethod { .put }
    public var path: String {
        return "\(context.pathComponent)/usage_rights"
    }
}
