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

import Combine
import CoreData

public class SubmissionCompletedNotificationsSender {
    private let context: NSManagedObjectContext
    private let localNotifications: LocalNotificationsInteractor

    public init(
        context: NSManagedObjectContext,
        localNotifications: LocalNotificationsInteractor = LocalNotificationsInteractor()
    ) {
        self.context = context
        self.localNotifications = localNotifications
    }

    func sendSuccessNofitications(fileSubmissionID: NSManagedObjectID, apiSubmission: CreateSubmissionRequest.Response) -> Future<Void, Never> {
        Future<Void, Never> { [context, localNotifications] promise in
            context.perform {
                defer { promise(.success(())) }
                guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else {
                    return
                }

                let courseID = submission.courseID
                let assignmentID = submission.assignmentID

                NotificationCenter.default.post(
                    name: UploadManager.AssignmentSubmittedNotification,
                    object: nil,
                    userInfo: ["assignmentID": assignmentID, "submission": apiSubmission]
                )
                NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
                localNotifications.sendCompletedNotification(
                    courseID: courseID,
                    assignmentID: assignmentID
                )
            }
        }
    }

    func sendFailedNotification(fileSubmissionID: NSManagedObjectID) {
        context.perform { [context, localNotifications] in
            guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else {
                return
            }

            localNotifications.sendFailedNotification(
                courseID: submission.courseID,
                assignmentID: submission.assignmentID
            )
        }
    }
}
