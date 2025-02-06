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
    let category: SupportedCategories
    let notificationIDs: [String]
    let frequence: Frequency
    let title: String = ""
    let subtitle: String = ""
    let type: NotificationChannel.ChannelType

    enum SupportedCategories: String, CaseIterable {
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
        if let category = NotificationPreference.SupportedCategories(rawValue: notificationCategory.category) {
            self.category = category
        } else {
            return nil
        }

        self.notificationIDs = notificationCategory.notifications
        self.channelID = notificationCategory.channelID

        switch notificationCategory.frequency {
        case .immediately: self.frequence = .immediate
        case .never: self.frequence = .never
        default: self.frequence = .never
        }
        self.type = type
    }
}
