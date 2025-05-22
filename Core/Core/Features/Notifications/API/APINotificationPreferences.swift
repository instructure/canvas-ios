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

// https://canvas.instructure.com/doc/api/notification_preferences.html#NotificationPreference
public struct APINotificationPreference: Codable {
    let notification: String?
    let category: String?
    let frequency: NotificationFrequency
}

public enum NotificationFrequency: String, CaseIterable, Codable, OptionItemIdentifiable {
    case immediately, daily, weekly, never

    var name: String {
        switch self {
        case .immediately:
            return String(localized: "Immediately", bundle: .core)
        case .daily:
            return String(localized: "Daily", bundle: .core)
        case .weekly:
            return String(localized: "Weekly", bundle: .core)
        case .never:
            return String(localized: "Never", bundle: .core)
        }
    }

    var label: String {
        switch self {
        case .immediately:
            return String(localized: "Notify me right away", bundle: .core)
        case .daily:
            return String(localized: "Send daily summary", bundle: .core)
        case .weekly:
            return String(localized: "Send weekly summary", bundle: .core)
        case .never:
            return String(localized: "Do not send me anything", bundle: .core)
        }
    }
}

#if DEBUG
extension APINotificationPreference {
    public static func make(
        notification: String = "notification",
        category: String = "category",
        frequency: NotificationFrequency = .never
    ) -> APINotificationPreference {
        return APINotificationPreference(
            notification: notification,
            category: category,
            frequency: frequency
        )
    }
}
#endif

struct GetNotificationDefaultsFlagRequest: APIRequestable {
    struct Response: Codable {
        let data: String
    }

    var path: String { "users/self/custom_data/data_sync" }
    var query: [APIQueryItem] { [
        .value("ns", "MOBILE_CANVAS_USER_NOTIFICATION_STATUS_SETUP")
    ] }
}

struct PutNotificationDefaultsFlagRequest: APIRequestable {
    struct Response: Codable {
        let data: String
    }

    struct Body: Codable {
        let ns: String
        let data: String
    }

    var method: APIMethod { .put }
    var path: String { "users/self/custom_data/data_sync" }
    var body: Body? { Body(
        ns: "MOBILE_CANVAS_USER_NOTIFICATION_STATUS_SETUP",
        data: "true"
    ) }
}

// https://canvas.instructure.com/doc/api/notification_preferences.html#method.notification_preferences.index
struct GetNotificationPreferencesRequest: APIRequestable {
    struct Response: Codable {
        let notification_preferences: [APINotificationPreference]
    }

    let channelID: String

    var path: String {
        return "users/self/communication_channels/\(channelID)/notification_preferences"
    }
}

// https://canvas.instructure.com/doc/api/notification_preferences.html#method.notification_preferences.update_all
struct PutNotificationPreferencesRequest: APIRequestable {
    typealias Response = GetNotificationPreferencesRequest.Response
    struct Body: Encodable, Equatable {
        let notification_preferences: [String: [String: NotificationFrequency]]
    }

    let channelID: String
    let notifications: [String]
    let frequency: NotificationFrequency

    let method = APIMethod.put
    var path: String {
        return "users/self/communication_channels/\(channelID)/notification_preferences"
    }
    var body: Body? {
        return Body(notification_preferences: notifications.reduce(into: [:]) { json, notification in
            json[notification] = [ "frequency": frequency ]
        })
    }
}
