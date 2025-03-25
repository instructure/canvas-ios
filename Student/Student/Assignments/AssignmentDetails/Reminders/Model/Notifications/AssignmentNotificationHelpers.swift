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

import UserNotifications

public extension Sequence where Element == UNNotificationRequest {

    func filter(courseId: String? = nil,
                assignmentId: String? = nil,
                userId: String) -> [UNNotificationRequest] {
        typealias Keys = UNMutableNotificationContent.AssignmentReminderKeys
        return filter {
            let userInfo = $0.content.userInfo
            let hasUserId = userInfo[Keys.userId.rawValue] as? String == userId
            let hasCourseId = {
                guard let courseId else { return true }
                return userInfo[Keys.courseId.rawValue] as? String == courseId
            }()
            let hasAssignmentId = {
                guard let assignmentId else { return true }
                return userInfo[Keys.assignmentId.rawValue] as? String == assignmentId
            }()
            return hasCourseId && hasAssignmentId && hasUserId
        }
    }

    func sorted() -> [UNNotificationRequest] {
        sorted {
            guard let leftTrigger = $0.trigger as? UNCalendarNotificationTrigger,
                  let leftDate = leftTrigger.nextTriggerDate(),
                  let rightTrigger = $1.trigger as? UNCalendarNotificationTrigger,
                  let rightDate = rightTrigger.nextTriggerDate()
            else {
                return true
            }

            return leftDate.timeIntervalSince1970 > rightDate.timeIntervalSince1970
        }
    }

    func hasTriggerForTheSameTime(timeTrigger: UNCalendarNotificationTrigger) -> Bool {
        guard let triggerDate = timeTrigger.nextTriggerDate() else {
            return false
        }

        return contains {
            guard let oldTimeTrigger = $0.trigger as? UNCalendarNotificationTrigger,
                  let oldTriggerDate = oldTimeTrigger.nextTriggerDate()
            else {
                return false
            }
            return abs(triggerDate.timeIntervalSince1970 - oldTriggerDate.timeIntervalSince1970) < 1
        }
    }
}
