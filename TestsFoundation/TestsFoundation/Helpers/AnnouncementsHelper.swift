//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class AnnouncementsHelper: BaseHelper {
    public static var addNewAnnouncement: XCUIElement { app.find(label: "Create Announcement") }
    public static var emptyAnnouncements: XCUIElement { app.find(label: "No Announcements") }
    public static func cell(index: Int) -> XCUIElement {
        return app.find(id: "announcements.list.announcement.row-\(index)")
    }

    public struct Details {
        public static var title: XCUIElement { app.find(id: "DiscussionDetails.title") }
        public static var optionButton: XCUIElement { app.find(label: "Options") }
        public static var replyButton: XCUIElement { app.find(label: "Reply to main discussion") }
        public static var message: XCUIElement {
            app.find(id: "DiscussionDetails.body").findAll(type: .staticText, minimumCount: 2)[1]
        }

        public static func detailsByText(text: String) -> XCUIElement { return app.find(label: text) }

        public static func navBar(course: DSCourse) -> XCUIElement {
            app.find(id: "Announcement Details, \(course.name)")
        }
    }

    public static func notificationTitle(announcement: DSAccountNotification) -> XCUIElement {
        app.find(id: "AccountNotification.\(announcement.id).title")
    }

    public static func notificationMessage(announcement: DSAccountNotification) -> XCUIElement {
        app.find(id: "AccountNotification.\(announcement.id).body").find(type: .staticText)
    }

    public static func navigateToAnnouncementsPage(course: DSCourse, shouldPullToRefresh: Bool = false) {
        DashboardHelper.courseCard(course: course).hit()
        if shouldPullToRefresh {
            pullToRefresh()
        }
        CourseDetailsHelper.cell(type: .announcements).hit()
    }

    @discardableResult
    public static func createAnnouncements(course: DSCourse, count: Int = 1, titles: [String]? = nil, messages: [String]? = nil) -> [DSDiscussionTopic] {
        var announcements = [DSDiscussionTopic]()
        for i in 1...count {
            let announcementTitle = titles?[i] ?? "Sample Announcement \(i)"
            let announcementMessage = messages?[i] ?? "This is the message of Sample Announcement \(i)"
            announcements.append(seeder.createDiscussion(courseId: course.id, requestBody: .init(title: announcementTitle, message: announcementMessage, is_announcement: true, published: true)))
        }
        return announcements
    }

    public static func postAccountNotification(
            subject: String? = nil, message: String? = nil, isK5: Bool = false, durationMinutes: Int = 2) -> DSAccountNotification {
        let globalAnnouncementSubject = subject ?? "This is not a drill!"
        let globalAnnouncementMessage = message ?? "This is an account notification! Will disappear in \(durationMinutes) minutes"
        let globalAnnouncementStartAt = Date.now
        let globalAnnouncementEndAt = Date.now.addMinutes(durationMinutes)

        return seeder.postAccountNotifications(
            requestBody: .init(subject: globalAnnouncementSubject,
                               message: globalAnnouncementMessage,
                               start_at: globalAnnouncementStartAt,
                               end_at: globalAnnouncementEndAt),
            isK5: isK5)
    }
}
