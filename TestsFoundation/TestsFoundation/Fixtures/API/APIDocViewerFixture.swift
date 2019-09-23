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
        bgColor: String? = nil,
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
            bgColor: bgColor,
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
        rotations: [String: UInt]? = nil,
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
