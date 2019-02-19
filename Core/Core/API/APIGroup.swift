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

// https://canvas.instructure.com/doc/api/groups.html#Group
public struct APIGroup: Codable, Equatable {
    let id: ID
    let name: String
    let concluded: Bool
    // let description: String?
    // let is_public: Bool
    // let followed_by_user: Bool
    // let join_level: JoinLevel
    let members_count: Int
    let avatar_url: URL?
    // let context_type: String
    let course_id: ID?
    // let role: String?
    let group_category_id: ID
    // let sis_group_id: String?
    // let sis_import_id: String?
    // let storage_quota_mb: String
    let permissions: Permissions?

    struct Permissions: Codable, Equatable {
        let create_announcement: Bool
        let create_discussion_topic: Bool
    }
}
