//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

public class FileSubmission: NSManagedObject {
    @NSManaged public var userID: String
    @NSManaged public var submitted: Bool
    @NSManaged public var error: String?
    @NSManaged public var comment: String?
    @NSManaged public var started: Bool

    @NSManaged public var assignment: Assignment
    @NSManaged public var fileUploads: Set<FileUpload>?

    public var failed: Bool {
        return error != nil || fileUploads?.first { $0.error != nil } != nil
    }

    var readyToSubmit: Bool {
        return error == nil && fileUploads?.allSatisfy { $0.completed } == true
    }

    var next: FileUpload? {
        return fileUploads?.filter { $0.error == nil && !$0.completed && $0.taskID == nil }.first
    }

    func addToFileUploads(_ value: FileUpload) {
        fileUploads?.insert(value)
    }

    public var inProgress: Bool {
        return started && !submitted && !failed
    }
}

extension FileSubmission: Scoped {
    public enum ScopeKeys {
        case assignment(String)
    }

    public static func scope(forName name: FileSubmission.ScopeKeys) -> Scope {
        switch name {
        case .assignment(let assignmentID):
            return Scope.where(#keyPath(FileSubmission.assignment.id), equals: assignmentID)
        }
    }
}

// MARK: Notifications
extension FileSubmission {
    public static func sendFailedNotification(courseID: String, assignmentID: String, manager: NotificationManager = .shared) {
        let route = Route.course(courseID, assignment: assignmentID)
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)
        manager.notify(title: title, body: body, route: route)
    }

    public static func sendCompletedNotification(courseID: String, assignmentID: String, manager: NotificationManager = .shared) {
        let route = Route.course(courseID, assignment: assignmentID)
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submitted!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Your files were uploaded and the assignment was submitted successfully.", arguments: nil)
        manager.notify(title: title, body: body, route: route)
    }

}
