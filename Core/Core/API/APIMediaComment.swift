//
// Copyright (C) 2019-present Instructure, Inc.
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

public struct APIMediaComment: Codable, Equatable {
    let content_type: String
    let display_name: String?
    let media_id: String
    let media_type: String
    let url: URL

    enum CodingKeys: String, CodingKey {
        case content_type = "content-type"
        case display_name = "display_name"
        case media_id = "media_id"
        case media_type = "media_type"
        case url = "url"
    }
}
