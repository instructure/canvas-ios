//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core

extension APIFile {
    public static func make(
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
        mime_class: String = "JPEG",
        media_entry_id: String? = nil,
        locked_for_user: Bool = false,
        lock_info: String? = nil,
        lock_explanation: String? = nil,
        preview_url: URL? = nil
    ) -> APIFile {
        return APIFile(
            id: id,
            uuid: uuid,
            folder_id: folder_id,
            display_name: display_name,
            filename: filename,
            contentType: contentType,
            url: url,
            size: size,
            created_at: created_at,
            updated_at: updated_at,
            unlock_at: unlock_at,
            locked: locked,
            hidden: hidden,
            lock_at: lock_at,
            hidden_for_user: hidden_for_user,
            thumbnail_url: thumbnail_url,
            modified_at: modified_at,
            mime_class: mime_class,
            media_entry_id: media_entry_id,
            locked_for_user: locked_for_user,
            lock_info: lock_info,
            lock_explanation: lock_explanation,
            preview_url: preview_url
        )
    }
}
