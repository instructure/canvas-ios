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

public struct PutNotificationCategory: APIUseCase {
    public typealias Model = NotificationCategory

    let channelID: String
    let category: String
    let notifications: [String]
    let frequency: NotificationFrequency

    public let cacheKey: String? = nil

    public var request: PutNotificationPreferencesRequest {
        return PutNotificationPreferencesRequest(channelID: channelID, notifications: notifications, frequency: frequency)
    }

    public init(channelID: String, category: String, notifications: [String], frequency: NotificationFrequency) {
        self.channelID = channelID
        self.category = category
        self.notifications = notifications
        self.frequency = frequency
    }

    public func write(response: Request.Response?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        guard response != nil else { return }
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(NotificationCategory.channelID), channelID,
                                    #keyPath(NotificationCategory.category), category)
        let model: NotificationCategory = client.fetch(predicate).first ?? client.insert()
        model.channelID = channelID
        model.category = category
        model.frequency = frequency
        model.notifications = notifications
    }
}
