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
@testable import Core

extension APIMediaComment {
    public static func make(
        content_type: String = "video/mp4",
        display_name: String? = "Submission",
        media_id: String = "m-1234567890",
        media_type: MediaCommentType = .video,
        url: URL = URL(string: "https://google.com")!
    ) -> APIMediaComment {
        return APIMediaComment(
            content_type: content_type,
            display_name: display_name,
            media_id: media_id,
            media_type: media_type,
            url: url
        )
    }
}
