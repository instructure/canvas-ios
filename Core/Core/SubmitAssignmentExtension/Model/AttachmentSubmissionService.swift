//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class AttachmentSubmissionService {
    private let uploadManager: UploadManager

    public init(uploadManager: UploadManager = UploadManager(identifier: "com.instructure.icanvas.SubmitAssignment.file-uploads", sharedContainerIdentifier: "group.instructure.shared")) {
        self.uploadManager = uploadManager
    }

    public func submit(urls: [URL], courseID: String, assignmentID: String, comment: String?, callback: @escaping () -> Void) {
        let uploadContext = FileUploadContext.submission(
            courseID: courseID,
            assignmentID: assignmentID,
            comment: comment
        )
        let batchID = "assignment-\(assignmentID)"
        uploadManager.cancel(batchID: batchID)
        let semaphore = DispatchSemaphore(value: 0)
        var error: Error?
        ProcessInfo.processInfo.performExpiringActivity(withReason: "get upload targets") { expired in
            if expired {
                Analytics.shared.logError("error_performing_background_activity")
                self.uploadManager.notificationManager.sendFailedNotification()
                return
            }
            self.uploadManager.viewContext.perform {
                do {
                    var files: [File] = []
                    for url in urls {
                        let file = try self.uploadManager.add(url: url, batchID: batchID)
                        files.append(file)
                    }
                    for file in files {
                        self.uploadManager.upload(file: file, to: uploadContext) {
                            semaphore.signal()
                        }
                    }
                } catch let e {
                    error = e
                }
            }
            if error != nil {
                self.uploadManager.notificationManager.sendFailedNotification()
            }
            semaphore.wait()
            callback()
        }
    }
}
