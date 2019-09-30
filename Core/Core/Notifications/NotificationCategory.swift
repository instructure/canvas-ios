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
import CoreData

class NotificationCategory: NSManagedObject {
    @NSManaged var channelID: String
    @NSManaged var category: String
    @NSManaged var frequencyRaw: String
    @NSManaged var notificationsRaw: String

    var frequency: NotificationFrequency {
        get { return NotificationFrequency(rawValue: frequencyRaw) ?? .never }
        set { frequencyRaw = newValue.rawValue }
    }

    var notifications: [String] {
        get { return notificationsRaw.components(separatedBy: ",") }
        set { notificationsRaw = newValue.joined(separator: ",") }
    }
}

struct GetNotificationCategories: CollectionUseCase {
    typealias Model = NotificationCategory

    let channelID: String

    var cacheKey: String? {
        return request.path
    }

    var scope: Scope {
        return .where(
            #keyPath(NotificationCategory.channelID), equals: channelID,
            orderBy: #keyPath(NotificationCategory.category)
        )
    }

    var request: GetNotificationPreferencesRequest {
        return GetNotificationPreferencesRequest(channelID: channelID)
    }

    func write(response: Request.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let preferences = response?.notification_preferences else { return }
        var categories: [String: ([String], NotificationFrequency)] = [:]
        for pref in preferences {
            categories[pref.category] = categories[pref.category] ?? ([], pref.frequency)
            categories[pref.category]?.0.append(pref.notification)
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

struct PutNotificationCategory: APIUseCase {
    typealias Model = NotificationCategory

    let channelID: String
    let category: String
    let notifications: [String]
    let frequency: NotificationFrequency

    let cacheKey: String? = nil

    var request: PutNotificationPreferencesRequest {
        return PutNotificationPreferencesRequest(channelID: channelID, notifications: notifications, frequency: frequency)
    }

    func write(response: Request.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard response != nil else { return }
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
