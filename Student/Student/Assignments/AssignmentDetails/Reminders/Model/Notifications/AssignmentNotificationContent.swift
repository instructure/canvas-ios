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

extension UNNotificationContent {
    enum Keys: String {
        case courseId, assignmentId, userId
    }

    static func assignmentReminder(context: AssignmentReminderContext, beforeTime: DateComponents) -> UNNotificationContent {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        let dueText = formatter.string(from: beforeTime) ?? ""

        let result = UNMutableNotificationContent()
        result.title = String(localized: "Due Date Reminder")
        result.body = String(localized: "This assignment is due in \(dueText)", comment: "Due in 5 minutes") + ": \(context.assignmentName)"
        result.userInfo = [
            Keys.courseId.rawValue: context.courseId,
            Keys.assignmentId.rawValue: context.assignmentId,
            Keys.userId.rawValue: context.userId,
            NotificationManager.RouteURLKey: "courses/\(context.courseId)/assignments/\(context.assignmentId)",
        ]
        return result
    }
}
