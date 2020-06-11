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
    let notification: String
    let category: String
    let frequency: NotificationFrequency
}

public enum NotificationFrequency: String, CaseIterable, Codable {
    case immediately, daily, weekly, never

    var name: String {
        switch self {
        case .immediately:
            return NSLocalizedString("Immediately", bundle: .core, comment: "")
        case .daily:
            return NSLocalizedString("Daily", bundle: .core, comment: "")
        case .weekly:
            return NSLocalizedString("Weekly", bundle: .core, comment: "")
        case .never:
            return NSLocalizedString("Never", bundle: .core, comment: "")
        }
    }

    var label: String {
        switch self {
        case .immediately:
            return NSLocalizedString("Notify me right away", bundle: .core, comment: "")
        case .daily:
            return NSLocalizedString("Send daily summary", bundle: .core, comment: "")
        case .weekly:
            return NSLocalizedString("Send weekly summary", bundle: .core, comment: "")
        case .never:
            return NSLocalizedString("Do not send me anything", bundle: .core, comment: "")
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
