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

// https://canvas.instructure.com/doc/api/files.html#File
public struct APIFile: Codable, Equatable {
    let id: ID
    let uuid: String
    let folder_id: ID
    let display_name: String
    let filename: String
    let contentType: String
    let url: URL
    // file size in bytes
    let size: Int
    let created_at: Date
    let updated_at: Date
    let unlock_at: Date?
    let locked: Bool
    let hidden: Bool
    let lock_at: Date?
    let hidden_for_user: Bool
    let thumbnail_url: URL?
    let modified_at: Date
    // simplified content-type mapping
    let mime_class: String
    // identifier for file in third-party transcoding service
    let media_entry_id: String?
    let locked_for_user: Bool
    let lock_info: String?
    let lock_explanation: String?
    // optional: url to the document preview. This url is specific to the user
    // making the api call. Only included in submission endpoints.
    let preview_url: URL?

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
        case lock_info = "lock_info"
        case lock_explanation = "lock_explanation"
        case preview_url = "preview_url"
    }
}
