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

extension UNNotificationContent {
    enum AssignmentReminderKeys: String {
        case courseId, assignmentId, userId, triggerTimeText
    }

    static func assignmentReminder(context: AssignmentReminderContext, beforeTime: DateComponents) -> UNNotificationContent {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        let dueText = formatter.string(from: beforeTime) ?? ""

        let result = UNMutableNotificationContent()
        result.title = String(localized: "Due Date Reminder", bundle: .student)
        result.body = String(localized: "This assignment is due in \(dueText)", bundle: .student, comment: "Due in 5 minutes") + ": \(context.assignmentName)"
        result.sound = .default
        result.userInfo = [
            AssignmentReminderKeys.courseId.rawValue: context.courseId,
            AssignmentReminderKeys.assignmentId.rawValue: context.assignmentId,
            AssignmentReminderKeys.userId.rawValue: context.userId,
            AssignmentReminderKeys.triggerTimeText.rawValue: AssignmentReminderTimeFormatter().string(from: beforeTime) ?? "",
            UNNotificationContent.RouteURLKey: "courses/\(context.courseId)/assignments/\(context.assignmentId)"
        ]
        return result
    }
}
