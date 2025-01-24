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

import CoreData

public struct FileSubmissionBackgroundTerminationHandler {
    private let context: NSManagedObjectContext
    private let notificationsSender: SubmissionCompletedNotificationsSender

    public init(context: NSManagedObjectContext, notificationsSender: SubmissionCompletedNotificationsSender) {
        self.context = context
        self.notificationsSender = notificationsSender
    }

    func handleTermination(fileUploadItemID: NSManagedObjectID) {
        context.performAndWait {
            guard let fileUploadItem = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem else { return }
            let errorDescription = String(localized: "The submission process was terminated by the operating system.", bundle: .core)
            let notSubmitted = !fileUploadItem.fileSubmission.isSubmitted

            if fileUploadItem.apiID == nil {
                fileUploadItem.uploadError = errorDescription
            } else if notSubmitted {
                fileUploadItem.fileSubmission.submissionError = errorDescription
            }

            try? context.save()

            if notSubmitted {
                notificationsSender.sendFailedNotification(fileSubmissionID: fileUploadItem.fileSubmission.objectID)
            }
        }
    }
}
