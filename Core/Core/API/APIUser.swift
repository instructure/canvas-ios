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

// https://canvas.instructure.com/doc/api/users.html#UserDisplay
struct APIUserDisplay: Codable, Equatable {
    let id: ID
    let short_name: String
    let avatar_image_url: APIURL?
    let html_url: URL
}

// https://canvas.instructure.com/doc/api/users.html#User
public struct APIUser: Codable, Equatable {
    let id: ID
    let name: String
    let sortable_name: String
    let short_name: String
    // let sis_user_id: String?
    // let sis_import_id: String?
    // let integration_id: String?
    let login_id: String?
    let avatar_url: APIURL?
    let enrollments: [APIEnrollment]?
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

public struct APIUserSettings: Codable, Equatable {
    let manual_mark_as_read: Bool
    let collapse_global_nav: Bool
    let hide_dashcard_color_overlays: Bool
}

// https://canvas.instructure.com/doc/api/users.html#Profile
public struct APIProfile: Codable, Equatable {
    public struct APICalendar: Codable, Equatable {
        public let ics: URL?
    }

    public let id: ID
    public let name: String
    public let primary_email: String?
    public let login_id: String?
    public let avatar_url: APIURL?
    public let calendar: APICalendar?
}
