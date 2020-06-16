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
    public let id: ID
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
    let pronouns: String?

    public let permissions: Permissions?
    public struct Permissions: Codable, Equatable {
        public let can_update_name: Bool?
        public let can_update_avatar: Bool?
        public let limit_parent_app_web_access: Bool?
    }
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
    public let pronouns: String?
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
        permissions: Permissions? = .make()
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
            permissions: permissions
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

extension APIUserSettings {
    public static func make(
        manual_mark_as_read: Bool = false,
        collapse_global_nav: Bool = false,
        hide_dashcard_color_overlays: Bool = false
    ) -> APIUserSettings {
        return APIUserSettings(
            manual_mark_as_read: manual_mark_as_read,
            collapse_global_nav: collapse_global_nav,
            hide_dashcard_color_overlays: hide_dashcard_color_overlays
        )
    }
}

extension APIProfile {
    public static func make(
        id: ID = "1",
        name: String = "Bob",
        primary_email: String? = nil,
        login_id: String? = nil,
        avatar_url: URL? = nil,
        calendar: APIProfile.APICalendar? = .make(),
        pronouns: String? = nil
    ) -> APIProfile {
        return APIProfile(
            id: id,
            name: name,
            primary_email: primary_email,
            login_id: login_id,
            avatar_url: avatar_url.flatMap(APIURL.make(rawValue:)),
            calendar: calendar,
            pronouns: pronouns
        )
    }
}

extension APIProfile.APICalendar {
    public static func make(ics: URL? = URL(string: "https://calendar.url")) -> APIProfile.APICalendar {
        return APIProfile.APICalendar(ics: ics)
    }
}
#endif

// https://canvas.instructure.com/doc/api/users.html#method.users.get_custom_color
public struct GetCustomColorsRequest: APIRequestable {
    public typealias Response = APICustomColors

    public let path = "users/self/colors"
}

// https://canvas.instructure.com/doc/api/users.html#method.users.api_show
public struct GetUserRequest: APIRequestable {
    public typealias Response = APIUser

    public let userID: String

    public init(userID: String) {
        self.userID = userID
    }

    public var path: String {
        return Context(.user, id: userID).pathComponent
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.create
struct CreateUserRequest: APIRequestable {
    typealias Response = APIUser
    struct Body: Codable, Equatable {
        struct User: Codable, Equatable {
            let name: String
        }

        struct Pseudonym: Codable, Equatable {
            let unique_id: String
            let password: String
        }

        let user: User
        let pseudonym: Pseudonym
    }

    let accountID: String

    let body: Body?
    let method = APIMethod.post
    var path: String {
        return "\(Context(.account, id: accountID).pathComponent)/users"
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.update
struct PutUserAvatarRequest: APIRequestable {
    typealias Response = APIUser

    struct Body: Encodable {
        let user: User
    }
    struct User: Encodable {
        let avatar: Avatar
    }
    struct Avatar: Encodable {
        let token: String
    }

    let token: String

    let method = APIMethod.put
    let path = "users/self"
    var body: Body? {
        return Body(user: User(avatar: Avatar(token: token)))
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.set_custom_color
struct UpdateCustomColorRequest: APIRequestable {
    struct Response: Codable {
        let hexcode: String // does include '#'
    }
    struct Body: Codable, Equatable {
        let hexcode: String // does NOT include '#'
    }

    let userID: String
    let context: Context

    let body: Body?
    let method = APIMethod.put
    var path: String {
        return "users/\(userID)/colors/\(context.canvasContextID)"
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.settings
public struct GetUserSettingsRequest: APIRequestable {
    public typealias Response = APIUserSettings

    let userID: String

    public var path: String {
        return "users/\(userID)/settings"
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.settings
public struct PutUserSettingsRequest: APIRequestable {
    public typealias Response = APIUserSettings
    public struct Body: Encodable {
        let manual_mark_as_read: Bool?
        let collapse_global_nav: Bool?
        let hide_dashcard_color_overlays: Bool?
    }

    public let method = APIMethod.put
    public let path = "users/self/settings"
    public let body: Body?

    init(manual_mark_as_read: Bool? = nil, collapse_global_nav: Bool? = nil, hide_dashcard_color_overlays: Bool? = nil) {
        body = Body(
            manual_mark_as_read: manual_mark_as_read,
            collapse_global_nav: collapse_global_nav,
            hide_dashcard_color_overlays: hide_dashcard_color_overlays
        )
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.profile.settings
public struct GetUserProfileRequest: APIRequestable {
    public typealias Response = APIProfile

    public let userID: String

    public var path: String {
        let context = Context(.user, id: userID)
        return "\(context.pathComponent)/profile"
    }

    public init(userID: String) {
        self.userID = userID
    }
}

// https://canvas.instructure.com/doc/api/user_observees.html#method.user_observees.create
public struct PostObserveesRequest: APIRequestable {
    public typealias Response = APIUser

    public let userID: String
    public let pairingCode: String?

    public init(userID: String, pairingCode: String? = nil) {
        self.userID = userID
        self.pairingCode = pairingCode
    }

    public let method: APIMethod = .post

    public var path: String {
        let context = Context(.user, id: userID)
        return "\(context.pathComponent)/observees"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        if let pairingCode = pairingCode {
            query.append(.value("pairing_code", pairingCode))
        }
        return query
    }
}

// https://canvas.instructure.com/doc/api/user_observees.html#method.user_observees.index
/* Does not return manually linked observees
public struct GetObserveesRequest: APIRequestable {
    public typealias Response = [APIUser]

    public let path = "users/self/observees"
    public let query: [APIQueryItem] = [
        .include([ "avatar_url" ]),
        .perPage(100),
    ]

    public init() {}
}
*/

// https://canvas.instructure.com/doc/api/user_observees.html#method.user_observees.show
/* Does not work with manually linked observees
public struct GetObserveeRequest: APIRequestable {
    public typealias Response = APIUser

    public let path: String
    public let query: [APIQueryItem] = [
        .include([ "avatar_url" ]),
    ]

    public init(observeeID: String) {
        path = "users/self/observees/\(observeeID)"
    }
}
*/
