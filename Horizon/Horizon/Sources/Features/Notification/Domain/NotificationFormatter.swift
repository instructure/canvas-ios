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

import Foundation

protocol NotificationFormatter {
    func formatNotifications(_ notifications: [HActivity], courses: [HCourse]) -> [NotificationModel]
}

final class NotificationFormatterLive: NotificationFormatter {
    func formatNotifications(_ notifications: [HActivity], courses: [HCourse]) -> [NotificationModel] {
        unowned let unownedSelf = self
        return notifications.map { notification in
            let course = courses.first(where: { $0.id == notification.courseId })
            return NotificationModel(
                id: notification.id,
                category: unownedSelf.getNotificationCategory(for: notification, course: course),
                title: unownedSelf.getTitle(for: notification, course: course),
                date: notification.dateFormatted,
                isRead: notification.isRead,
                courseID: course?.id ?? "",
                enrollmentID: course?.enrollmentID ?? "",
                isScoreAnnouncement: (unownedSelf.isAssignmentScored(notification) || unownedSelf.isGradingWeightChanged(notification))
            )
        }
    }

    private func getNotificationCategory(for notification: HActivity, course: HCourse?) -> String {
        if isAssignmentScored(notification) {
            return String(localized: "Assignment Scored", bundle: .horizon)
        }
        if isDueDateChanged(notification) {
            return String(localized: "Due Date Changed", bundle: .horizon)
        }
        if isGradingWeightChanged(notification) {
            return String(localized: "Scoring Weight Changed", bundle: .horizon)
        }
        if notification.contextType == "Course" {
            return "\(String(localized: "Announcement from", bundle: .horizon)) \(course?.name ?? String(localized: "Unknown Course", bundle: .horizon))"
        }
        return notification.notificationCategory ?? (notification.type?.rawValue ?? "")
    }

    private func getTitle(for notification: HActivity, course: HCourse?) -> String {
        if isAssignmentScored(notification) {
            return "\(notification.title) \(String(localized: "'s score is now available", bundle: .horizon))"
        }
        if isDueDateChanged(notification) {
            return formatDueDateTitle(for: notification, course: course)
        }
        if isAssignmentCreated(notification) {
            return notification.title.replacingOccurrences(of: ", \(course?.name ?? "")", with: "")
        }
        if isGradingWeightChanged(notification) {
            return formatGradingWeightChangeTitle(notification)
        }
        return notification.title
    }

    // MARK: - Helper Methods

    private func isAssignmentScored(_ notification: HActivity) -> Bool {
        return notification.grade != nil || notification.score != nil
    }

    private func isDueDateChanged(_ notification: HActivity) -> Bool {
        return notification.notificationCategory == HNotificationCategory.dueDate.rawValue &&
        notification.title.contains("Assignment Due Date Changed")
    }

    private func isAssignmentCreated(_ notification: HActivity) -> Bool {
        return notification.notificationCategory == HNotificationCategory.dueDate.rawValue &&
        notification.title.contains("Assignment Created")
    }

    private func isGradingWeightChanged(_ notification: HActivity) -> Bool {
        return notification.title.contains("Grading Weight Changed") ||
        notification.notificationCategory == HNotificationCategory.gradingPolicies.rawValue
    }

    private func formatDueDateTitle(for notification: HActivity, course: HCourse?) -> String {
        let assignmentName = notification.title
            .replacingOccurrences(of: "Assignment Due Date Changed: ", with: "")
            .replacingOccurrences(of: ", \(course?.name ?? "")", with: "")

        let dateComponents = notification.message?.components(separatedBy: "\n\n") ?? []
        let date = dateComponents[safe: 1] ?? String(localized: "Unknown date", bundle: .horizon)

        return "\(assignmentName) \(String(localized: "is due on ", bundle: .horizon))\(date)"
    }

    private func formatGradingWeightChangeTitle(_ notification: HActivity) -> String {
        let courseNameFromTitle = notification.title.replacingOccurrences(of: "Grade Weight Changed: ", with: "")
        return "\(courseNameFromTitle)\(String(localized: "'s score weight was changed  ", bundle: .horizon))"
    }
}

enum HNotificationCategory: String {
    case gradingPolicies = "Grading Policies"
    case dueDate = "Due Date"
}
