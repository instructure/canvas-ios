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

public struct APIMediaComment: Codable, Equatable {
    let content_type: String
    let display_name: String?
    let media_id: String
    let media_type: MediaCommentType
    let url: URL

    enum CodingKeys: String, CodingKey {
        case content_type = "content-type"
        case display_name = "display_name"
        case media_id = "media_id"
        case media_type = "media_type"
        case url = "url"
    }
}

// https://canvas.instructure.com/doc/api/services.html#method.services_api.show_kaltura_config
struct APIMediaService: Codable {
    let domain: String
}

// https://canvas.instructure.com/doc/api/services.html#method.services_api.start_kaltura_session
struct APIMediaSession: Codable {
    let ks: String
}

struct APIMediaIDWrapper: Codable {
    let id: String
}
