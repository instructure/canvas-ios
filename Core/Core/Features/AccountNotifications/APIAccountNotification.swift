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

// https://canvas.instructure.com/doc/api/account_notifications.html#AccountNotification
public struct APIAccountNotification: Codable {
    let end_at: Date?
    let icon: AccountNotificationIcon
    let id: ID
    let message: String
    // let role_ids: [String]
    let start_at: Date
    let subject: String
}

#if DEBUG
extension APIAccountNotification {
    public static func make(
        end_at: Date? = nil,
        icon: AccountNotificationIcon = .warning,
        id: ID = "1",
        message: String = "The financial aid office is closed on Tuesdays.",
        start_at: Date = Date(),
        subject: String = "Financial Aid"
    ) -> APIAccountNotification {
        return APIAccountNotification(
            end_at: end_at,
            icon: icon,
            id: id,
            message: message,
            start_at: start_at,
            subject: subject
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/account_notifications.html#method.account_notifications.user_index
public struct GetAccountNotificationsRequest: APIRequestable {
    public typealias Response = [APIAccountNotification]

    public let path = "accounts/self/account_notifications"
    public let query: [APIQueryItem] = [ .perPage(100) ]
}

// https://canvas.instructure.com/doc/api/account_notifications.html#method.account_notifications.show
public struct GetAccountNotificationRequest: APIRequestable {
    public typealias Response = APIAccountNotification

    let id: String
    public var path: String { "accounts/self/account_notifications/\(id)" }
}

// https://canvas.instructure.com/doc/api/account_notifications.html#method.account_notifications.user_close_notification
public struct DeleteAccountNotificationRequest: APIRequestable {
    public typealias Response = APINoContent

    let id: String

    public var method: APIMethod { .delete }
    public var path: String { "accounts/self/account_notifications/\(id)" }
}
