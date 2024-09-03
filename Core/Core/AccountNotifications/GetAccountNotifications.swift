//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import CoreData

struct GetAccountNotifications: CollectionUseCase {
    typealias Model = AccountNotification
    typealias Response = [APIAccountNotification]

    var cacheKey: String? { "accounts/self/account_notifications" }
    var request: GetAccountNotificationsRequest { GetAccountNotificationsRequest() }
    var scope: Scope { .all(orderBy: #keyPath(AccountNotification.endAt), ascending: false) }
}

public class GetAccountNotification: APIUseCase {
    public typealias Model = AccountNotification

    let notificationID: String

    public init(notificationID: String) {
        self.notificationID = notificationID
    }

    public var cacheKey: String? { "accounts/self/account_notifications/\(notificationID)" }
    public var request: GetAccountNotificationRequest {
        GetAccountNotificationRequest(id: notificationID)
    }
    public var scope: Scope { .where(#keyPath(AccountNotification.id), equals: notificationID) }
}

struct DeleteAccountNotification: DeleteUseCase {
    typealias Model = AccountNotification
    typealias Response = APINoContent

    let id: String

    var cacheKey: String? { nil }
    var request: DeleteAccountNotificationRequest { DeleteAccountNotificationRequest(id: id) }
    var scope: Scope { .where(#keyPath(AccountNotification.id), equals: id) }
}
