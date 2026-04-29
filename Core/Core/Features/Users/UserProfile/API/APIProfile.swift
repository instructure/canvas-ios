//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/users.html#Profile
public struct APIProfile: Codable, Equatable {
    public let id: ID
    public let name: String
    public let short_name: String?
    public let primary_email: String?
    public let locale: String?
    public let login_id: String?
    public let avatar_url: APIURL?
    public let calendar: APIProfile.APICalendar?
    public let pronouns: String?
    public let k5_user: Bool?
    public let uuid: String?
    public let account_uuid: String?
    public let time_zone: String?
    public let permissions: APIProfile.Permissions?
}

extension APIProfile {
    public struct APICalendar: Codable, Equatable {
        public let ics: URL?
    }

    public struct Permissions: Codable, Equatable {
        public let canUpdateName: Bool?
        public let canUpdateAvatar: Bool?

        enum CodingKeys: String, CodingKey {
            case canUpdateName = "can_update_name"
            case canUpdateAvatar = "can_update_avatar"
        }
    }
}

#if DEBUG

extension APIProfile {
    public static func make(
        id: ID = "1",
        name: String = "Bob",
        short_name: String? = nil,
        primary_email: String? = nil,
        locale: String? = "en",
        login_id: String? = nil,
        avatar_url: URL? = nil,
        calendar: APIProfile.APICalendar? = .make(),
        pronouns: String? = nil,
        k5_user: Bool? = nil,
        uuid: String? = nil,
        account_uuid: String? = nil,
        time_zone: String? = nil,
        permissions: APIProfile.Permissions? = nil
    ) -> APIProfile {
        return APIProfile(
            id: id,
            name: name,
            short_name: short_name,
            primary_email: primary_email,
            locale: locale,
            login_id: login_id,
            avatar_url: avatar_url.flatMap(APIURL.make(rawValue:)),
            calendar: calendar,
            pronouns: pronouns,
            k5_user: k5_user,
            uuid: uuid,
            account_uuid: account_uuid,
            time_zone: time_zone,
            permissions: permissions
        )
    }
}

extension APIProfile.APICalendar {
    public static func make(ics: URL? = URL(string: "https://calendar.url")) -> APIProfile.APICalendar {
        return APIProfile.APICalendar(ics: ics)
    }
}

#endif
