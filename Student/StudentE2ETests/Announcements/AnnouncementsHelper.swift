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

import Foundation
import TestsFoundation
import XCTest

enum AnnouncementList {
    static func cell(index: Int) -> Element {
        return app.find(id: "announcements.list.announcement.row-\(index)")
    }
}

public class AnnouncementsHelper: BaseHelper {
    struct Details {
        public static var title: Element { app.find(id: "DiscussionDetails.title") }
        public static var message: Element {
            app.find(id: "DiscussionDetails.body").rawElement.findAll(type: .staticText)[1]
        }

        public static func navBar(course: DSCourse) -> Element {
            app.find(id: "Announcement Details, \(course.name)")
        }
    }

    public static func notificationTitle(announcement: DSAccountNotification) -> Element {
        app.find(id: "AccountNotification.\(announcement.id).title")
    }

    public static func notificationMessage(announcement: DSAccountNotification) -> Element {
        app.find(id: "AccountNotification.\(announcement.id).body").rawElement.find(type: .staticText)
    }

    public static func navigateToAnnouncementsPage(course: DSCourse, shouldPullToRefresh: Bool = false) {
        Dashboard.courseCard(id: course.id).tap()
        if shouldPullToRefresh {
            pullToRefresh()
        }
        CourseNavigation.announcements.tap()
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

    public static func postAccountNotification(subject: String? = nil, message: String? = nil) -> DSAccountNotification {
        let dateFormatter = ISO8601DateFormatter()
        let globalAnnouncementSubject = subject ?? "This is a GA"
        let globalAnnouncementMessage = message ?? "This will disappear in 4 minutes"
        let globalAnnouncementStartAt = dateFormatter.string(from: Date().addMinutes(-1))
        let globalAnnouncementEndAt = dateFormatter.string(from: Date().addMinutes(3))

        return seeder.postAccountNotifications(requestBody:
                .init(subject: globalAnnouncementSubject, message: globalAnnouncementMessage,
                      start_at: globalAnnouncementStartAt, end_at: globalAnnouncementEndAt)
        )
    }
}
