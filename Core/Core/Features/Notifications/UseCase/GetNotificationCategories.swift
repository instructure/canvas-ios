//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import CoreData

public struct GetNotificationCategories: CollectionUseCase {
    public typealias Model = NotificationCategory

    let channelID: String

    public var cacheKey: String? {
        return request.path
    }

    public var scope: Scope {
        return .where(
            #keyPath(NotificationCategory.channelID), equals: channelID,
            orderBy: #keyPath(NotificationCategory.category)
        )
    }

    public var request: GetNotificationPreferencesRequest {
        return GetNotificationPreferencesRequest(channelID: channelID)
    }

    public init(channelID: String) {
        self.channelID = channelID
    }
    
    public func write(response: Request.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let preferences = response?.notification_preferences else { return }
        var categories: [String: ([String], NotificationFrequency)] = [:]
        for pref in preferences {
            if let category = pref.category, let notification = pref.notification {
                categories[category] = categories[category] ?? ([], pref.frequency)
                categories[category]?.0.append(notification)
            }
        }
        for (category, (notifications, frequency)) in categories {
            let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                #keyPath(NotificationCategory.channelID), channelID,
                #keyPath(NotificationCategory.category), category
            )
            let model: NotificationCategory = client.fetch(predicate).first ?? client.insert()
            model.channelID = channelID
            model.category = category
            model.frequency = frequency
            model.notifications = notifications
        }
    }
}
