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

extension APIDocViewerAnnotation {
    public static func make(
        id: String = "1",
        document_id: String? = nil,
        user_id: String? = "1",
        user_name: String = "a",
        page: UInt = 0,
        created_at: Date? = nil,
        modified_at: Date? = nil,
        deleted: Bool? = nil,
        deleted_at: Date? = nil,
        deleted_by: String? = nil,
        deleted_by_id: String? = nil,
        type: APIDocViewerAnnotationType = .text,
        color: String? = nil,
        icon: String? = nil,
        contents: String? = "contents",
        inreplyto: String? = nil,
        coords: [[[Double]]]? = nil,
        rect: [[Double]]? = nil,
        font: String? = nil,
        inklist: APIDocViewerInklist? = nil,
        width: Double? = nil
    ) -> APIDocViewerAnnotation {
        return APIDocViewerAnnotation(
            id: id,
            document_id: document_id,
            user_id: user_id,
            user_name: user_name,
            page: page,
            created_at: created_at,
            modified_at: modified_at,
            deleted: deleted,
            deleted_at: deleted_at,
            deleted_by: deleted_by,
            deleted_by_id: deleted_by_id,
            type: type,
            color: color,
            icon: icon,
            contents: contents,
            inreplyto: inreplyto,
            coords: coords,
            rect: rect,
            font: font,
            inklist: inklist,
            width: width
        )
    }
}

extension APIDocViewerMetadata {
    public static func make(
        annotations: APIDocViewerAnnotationsMetadata? = .make(),
        panda_push: APIDocViewerPandaPushMetadata? = nil,
        rotations: [String : UInt]? = nil,
        urls: APIDocViewerURLsMetadata = .make()
    ) -> APIDocViewerMetadata {
        return APIDocViewerMetadata(
            annotations: annotations,
            panda_push: panda_push,
            rotations: rotations,
            urls: urls
        )
    }
}

extension APIDocViewerAnnotationsMetadata {
    public static func make(
        enabled: Bool = true,
        user_id: String? = "1",
        user_name: String? = "Bob",
        permissions: APIDocViewerPermissions = .readwritemanage
    ) -> APIDocViewerAnnotationsMetadata {
        return APIDocViewerAnnotationsMetadata(
            enabled: enabled,
            user_id: user_id,
            user_name: user_name,
            permissions: permissions
        )
    }
}

extension APIDocViewerURLsMetadata {
    public static func make(
        pdf_download: URL = URL(string: "download")!
    ) -> APIDocViewerURLsMetadata {
        return APIDocViewerURLsMetadata(
            pdf_download: pdf_download
        )
    }
}
