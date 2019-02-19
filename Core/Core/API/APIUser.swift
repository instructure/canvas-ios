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

// https://canvas.instructure.com/doc/api/users.html#UserDisplay
struct APIUserDisplay: Codable, Equatable {
    let id: String
    let short_name: String
    let avatar_image_url: URL?
    let html_url: URL
}

// https://canvas.instructure.com/doc/api/users.html#User
struct APIUser: Codable, Equatable {
    let id: String
    let name: String
    let sortable_name: String
    let short_name: String
    // let sis_user_id: String?
    // let sis_import_id: String?
    // let integration_id: String?
    let login_id: String?
    let avatar_url: URL?
    // let enrollments: [APIEnrollment]?
    let email: String?
    let locale: String?
    let effective_locale: String?
    // let last_login: Date?
    // let time_zone: TimeZone
    let bio: String?
}

public struct APICustomColors: Codable, Equatable {
    let custom_colors: [String: String]
}
