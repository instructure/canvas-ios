//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public extension NotificationManager {

    func sendFailedNotification(courseID: String, assignmentID: String) {
        let identifier = "failed-submission-\(courseID)-\(assignmentID)"
        let route = "/courses/\(courseID)/assignments/\(assignmentID)"
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)
        notify(identifier: identifier, title: title, body: body, route: route)
    }

    func sendCompletedNotification(courseID: String, assignmentID: String) {
        let identifier = "completed-submission-\(courseID)-\(assignmentID)"
        let route = "/courses/\(courseID)/assignments/\(assignmentID)"
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submitted!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Your files were uploaded and the assignment was submitted successfully.", arguments: nil)
        notify(identifier: identifier, title: title, body: body, route: route)
    }

    func sendFailedNotification() {
        let title = NSString.localizedUserNotificationString(forKey: "Failed to send files!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with uploading files.", arguments: nil)
        notify(identifier: "upload-manager", title: title, body: body, route: nil)
    }
}
