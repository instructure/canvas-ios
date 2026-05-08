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

// https://canvas.instructure.com/doc/api/users.html#User
public struct APIUser: Codable, Equatable {
    public let id: ID
    public let name: String
    public let sortable_name: String
    public let short_name: String
    // let sis_user_id: String?
    // let sis_import_id: String?
    // let integration_id: String?
    public let login_id: String?
    public let avatar_url: APIURL?
    public let enrollments: [APIEnrollment]?
    public let email: String?
    public let effective_locale: String?
    // let last_login: Date?
    public let time_zone: String?
    public let bio: String?
    public let pronouns: String?
    public let root_account: String?

    public let locale: String?
    public let permissions: APIUser.Permissions?

    public init(
        id: ID,
        name: String,
        sortable_name: String,
        short_name: String,
        login_id: String?,
        avatar_url: APIURL?,
        enrollments: [APIEnrollment]?,
        email: String?,
        locale: String?,
        effective_locale: String?,
        bio: String?,
        pronouns: String?,
        permissions: APIUser.Permissions?,
        root_account: String?,
        time_zone: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sortable_name = sortable_name
        self.short_name = short_name
        self.login_id = login_id
        self.avatar_url = avatar_url
        self.enrollments = enrollments
        self.email = email
        self.locale = locale
        self.effective_locale = effective_locale
        self.bio = bio
        self.pronouns = pronouns
        self.permissions = permissions
        self.root_account = root_account
        self.time_zone = time_zone
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sortable_name = try container.decode(String.self, forKey: .sortable_name)
        short_name = try container.decode(String.self, forKey: .short_name)
        login_id = try container.decodeIfPresent(String.self, forKey: .login_id)
        avatar_url = try container.decodeURLIfPresent(forKey: .avatar_url)
        enrollments = try container.decodeIfPresent([APIEnrollment].self, forKey: .enrollments)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        locale = try container.decodeIfPresent(String.self, forKey: .locale)
        effective_locale = try container.decodeIfPresent(String.self, forKey: .effective_locale)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        pronouns = try container.decodeIfPresent(String.self, forKey: .pronouns)
        permissions = try container.decodeIfPresent(Permissions.self, forKey: .permissions)
        root_account = try container.decodeIfPresent(String.self, forKey: .root_account)
        time_zone = try container.decodeIfPresent(String.self, forKey: .time_zone)
    }
}

extension APIUser {
    public struct Permissions: Codable, Equatable {
        public let can_update_name: Bool?
        public let can_update_avatar: Bool?
        public let limit_parent_app_web_access: Bool?
    }
}

#if DEBUG

extension APIUser {
    public static func make(
        id: ID = "1",
        name: String = "Bob",
        sortable_name: String? = nil,
        short_name: String? = nil,
        login_id: String? = nil,
        avatar_url: URL? = nil,
        enrollments: [APIEnrollment]? = nil,
        email: String? = nil,
        locale: String? = "en",
        effective_locale: String? = nil,
        bio: String? = nil,
        pronouns: String? = nil,
        permissions: Permissions? = .make(),
        root_account: String? = nil,
        time_zone: String? = nil
    ) -> APIUser {
        return APIUser(
            id: id,
            name: name,
            sortable_name: sortable_name ?? name,
            short_name: short_name ?? name,
            login_id: login_id,
            avatar_url: avatar_url.flatMap(APIURL.make(rawValue:)),
            enrollments: enrollments,
            email: email,
            locale: locale,
            effective_locale: effective_locale,
            bio: bio,
            pronouns: pronouns,
            permissions: permissions,
            root_account: root_account,
            time_zone: time_zone
        )
    }

    public static func makeUser(role: String, id: Int) -> APIUser {
        APIUser.make(
            id: ID(integerLiteral: id),
            name: "\(role) \(id)",
            short_name: "\(role.first ?? "u")\(id)",

            avatar_url: URL(string: "https://avatars.dicebear.com/v2/bottts/\(role)\(id).svg")!,
            email: "\(role)\(id)@example.com",
            bio: "I'm \(role) \(id)",
            pronouns: ["Pro/Noun", nil][id % 2]
        )
    }
}

extension APIUser.Permissions {
    public static func make(
        can_update_name: Bool? = true,
        can_update_avatar: Bool? = true,
        limit_parent_app_web_access: Bool? = false
    ) -> APIUser.Permissions {
        return APIUser.Permissions(
            can_update_name: can_update_name,
            can_update_avatar: can_update_avatar,
            limit_parent_app_web_access: limit_parent_app_web_access
        )
    }
}

#endif
