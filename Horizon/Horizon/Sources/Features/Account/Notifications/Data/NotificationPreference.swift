//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct NotificationPreference {
    let channelID: String
    let category: VisibleCategories
    let associatedCategory: NotificationPreference.AssociatedCategories
    let notificationIDs: [String]
    var frequency: Frequency
    let type: NotificationChannel.ChannelType

    var isOn: Bool {
        switch frequency {
        case .immediate:
            return true
        case .never:
            return false
        }
    }

    enum VisibleCategories: String {
        case announcementsAndMesages
        case assignmentDueDates
        case scores

        // Notification preference categories presented on the UI may include more than 1 notification category
        // that comes from the the backend.
        init?(category: NotificationPreference.AssociatedCategories) {
            switch category {
            case .account_notification, .announcement, .conversation_message:
                self = .announcementsAndMesages
            case .due_date:
                self = .assignmentDueDates
            case .grading:
                self = .scores
            }
        }
    }

    enum AssociatedCategories: String, CaseIterable {
        case account_notification
        case announcement
        case conversation_message
        case due_date
        case grading
    }

    enum Frequency {
        case immediate
        case never
    }

    init?(from notificationCategory: NotificationCategory, type: NotificationChannel.ChannelType) {
        if let supportedCategory = NotificationPreference.AssociatedCategories(rawValue: notificationCategory.category),
           let category = NotificationPreference.VisibleCategories(category: supportedCategory) {
            self.associatedCategory = supportedCategory
            self.category = category
        } else {
            return nil
        }

        self.notificationIDs = notificationCategory.notifications
        self.channelID = notificationCategory.channelID

        switch notificationCategory.frequency {
        case .immediately: self.frequency = .immediate
        case .never: self.frequency = .never
        default: self.frequency = .never
        }
        self.type = type
    }
}

extension Array where Element == NotificationPreference {
    func getIsOn(
        for category: NotificationPreference.VisibleCategories,
        type: NotificationChannel.ChannelType
    ) -> Bool {
        filter { $0.category == category && $0.type == type }
            .compactMap { $0.isOn }
            .first ?? false
    }

    // Returns if push notifications are configured on the account.
    // It's not the same as registering for Apple Push Notification Services.
    func isPushNotificationConfigured() -> Bool {
        contains(where: { $0.type == .push })
    }
}
