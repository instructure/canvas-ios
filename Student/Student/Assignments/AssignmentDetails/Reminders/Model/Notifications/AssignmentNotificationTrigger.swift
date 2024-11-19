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

import Core
import UserNotifications

extension UNCalendarNotificationTrigger {

    convenience init(assignmentDueDate: Date,
                     beforeTime: DateComponents,
                     currentDate: Date = .now) throws {
        let negativeBeforeTime: DateComponents = {
            var result = beforeTime
            result.minute = result.minute.flatMap { -$0 }
            result.hour = result.hour.flatMap { -$0 }
            result.day = result.day.flatMap { -$0 }
            result.weekOfMonth = result.weekOfMonth.flatMap { -$0 }
            return result
        }()

        guard let triggerDate = Calendar.current.date(byAdding: negativeBeforeTime, to: assignmentDueDate) else {
            RemoteLogger.shared.logError(
                name: "Could not create assignment reminder trigger date",
                reason: "negativeBeforeTime: \(negativeBeforeTime)"
            )
            throw AssignmentReminderError.application
        }

        if triggerDate <= currentDate {
            throw AssignmentReminderError.reminderInPast
        }

        let triggerComponents = Calendar.current.dateComponents(Set([.year, .month, .day, .hour, .minute, .second, .nanosecond]), from: triggerDate)
        self.init(dateMatching: triggerComponents, repeats: false)
    }
}
