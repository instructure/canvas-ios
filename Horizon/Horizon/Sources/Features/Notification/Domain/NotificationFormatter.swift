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
import Foundation

protocol NotificationFormatter {
    func formatNotifications(_ notifications: [HActivity], courses: [HCourse]) -> [NotificationModel]
}

final class NotificationFormatterLive: NotificationFormatter {
    func formatNotifications(_ notifications: [HActivity], courses: [HCourse]) -> [NotificationModel] {
        unowned let unownedSelf = self
        return notifications.compactMap { notification in
            guard let course = courses.first(where: { $0.id == notification.courseId }),
                    let type = getNotificationTyep(for: notification) else { return nil }
            return NotificationModel(
                id: notification.id,
                title: notification.title,
                date: notification.date,
                isRead: notification.isRead,
                courseName: course.name,
                courseID: course.id,
                enrollmentID: course.enrollmentID,
                isScoreAnnouncement: (unownedSelf.isNotificationItemScored(notification) || unownedSelf.isGradingWeightChanged(notification)),
                type: type,
                announcementId: notification.announcementId,
                assignmentURL: notification.assignmentURL,
                htmlURL: notification.htmlURL
            )
        }
    }

    private func getNotificationTyep(for notification: HActivity) -> NotificationType? {
        if isNotificationItemScored(notification) {
            return .scoreChanged
        }
        if isDueDateChanged(notification) {
            return .dueDate
        }
        if isGradingWeightChanged(notification) {
            return .score
        }
        if notification.type == ActivityType.announcement {
            return .announcement
        }
        return nil
    }

    // MARK: - Helper Methods

    private func isNotificationItemScored(_ notification: HActivity) -> Bool {
        return notification.grade != nil || notification.score != nil
    }

    private func isDueDateChanged(_ notification: HActivity) -> Bool {
         notification.notificationCategory == HNotificationCategory.dueDate.rawValue
    }

    private func isGradingWeightChanged(_ notification: HActivity) -> Bool {
        notification.notificationCategory == HNotificationCategory.gradingPolicies.rawValue
    }
}

enum HNotificationCategory: String {
    case gradingPolicies = "Grading Policies"
    case dueDate = "Due Date"
}
