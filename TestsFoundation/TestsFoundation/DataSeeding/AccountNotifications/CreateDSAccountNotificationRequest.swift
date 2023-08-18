//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core

// https://canvas.instructure.com/doc/api/account_notifications.html#method.account_notifications.create
public struct CreateDSAccountNotificationRequest: APIRequestable {
    public typealias Response = DSAccountNotification

    public let method = APIMethod.post
    public let path: String
    public let body: Body?

    public init(body: Body, isK5: Bool = false) {
        let accountId = isK5 ? Secret.k5SubAccountId.string! : "self"
        self.path = "accounts/\(accountId)/account_notifications"
        self.body = body
    }
}

extension CreateDSAccountNotificationRequest {
    public struct RequestedDSAccountNotification: Encodable {
        let subject: String
        let message: String
        let start_at: Date
        let end_at: Date

        public init(subject: String, message: String, start_at: Date, end_at: Date) {
            self.subject = subject
            self.message = message
            self.start_at = start_at
            self.end_at = end_at
        }
    }

    public struct Body: Encodable {
        public let account_notification: RequestedDSAccountNotification
    }
}
