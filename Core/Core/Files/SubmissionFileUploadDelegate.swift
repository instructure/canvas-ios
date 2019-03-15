//
// Copyright (C) 2019-present Instructure, Inc.
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

public class SubmissionFileUploadDelegate: FileUploadDelegate {
    public let appGroup: AppGroup
    let notificationManager: NotificationManager

    public init(appGroup: AppGroup, notificationManager: NotificationManager = .shared) {
        self.appGroup = appGroup
        self.notificationManager = notificationManager
    }

    public func fileUploader(_ fileUploader: FileUploader, url: URL, didCompleteWithError error: Error?) {
        fileUploader.database.perform { context in
            guard let fileUpload: FileUpload = context.first(where: #keyPath(FileUpload.url), equals: url as CVarArg) else {
                return
            }
            guard let user = Keychain.entries.first(where: { $0 == fileUpload.user }) else {
                return
            }
            guard let target = fileUpload.context else {
                return
            }
            switch target {
            case let .submission(courseID: courseID, assignmentID: assignmentID):
                if let error = error {
                    Logger.shared.error("File upload failed with error \(error.localizedDescription)")
                    self.sendFailedNotification(courseID: courseID, assignmentID: assignmentID)
                    return
                }
                let files = self.submissionFiles(user: user, courseID: courseID, assignmentID: assignmentID)
                let predicate = NSPredicate(format: "%K in %@", #keyPath(FileUpload.url), files)
                let fileUploads: [FileUpload] = context.fetch(predicate)
                if !fileUploads.isEmpty && fileUploads.allSatisfy({ $0.completed && $0.error == nil }) {
                    let fileIDs = fileUploads.compactMap { $0.fileID }
                    self.submit(fileIDs: fileIDs, as: user, toAssignment: assignmentID, inCourse: courseID)
                }
            default:
                return
            }
        }
    }

    private func submit(fileIDs: [String], as user: KeychainEntry, toAssignment assignmentID: String, inCourse courseID: String) {
        let environment = AppEnvironment()
        environment.userDidLogin(session: user)
        let useCase = CreateSubmission(
            context: ContextModel(.course, id: courseID),
            assignmentID: assignmentID,
            userID: user.userID,
            submissionType: .online_upload,
            fileIDs: fileIDs
        )
        useCase.fetch { _, urlResponse, error in
            if let error = error {
                Logger.shared.error("File submission failed with error \(error.localizedDescription)")
                self.sendFailedNotification(courseID: courseID, assignmentID: assignmentID)
                return
            }
            if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 201 {
                Logger.shared.log("\(fileIDs.count) files submitted!")
                self.sendCompletedNotification(courseID: courseID, assignmentID: assignmentID)
                do {
                    // Delete all the files
                    for file in self.submissionFiles(user: user, courseID: courseID, assignmentID: assignmentID) {
                        try FileManager.default.removeItem(at: file)
                        Logger.shared.log("Removed local file submission")
                    }
                } catch {
                    Logger.shared.error(error.localizedDescription)
                }
            } else {
                Logger.shared.error("Unexpected file submission response")
                self.sendFailedNotification(courseID: courseID, assignmentID: assignmentID)
            }
        }
    }

    private func sendFailedNotification(courseID: String, assignmentID: String) {
        let route = Route.course(courseID, assignment: assignmentID)
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)
        notificationManager.notify(title: title, body: body, route: route)
    }

    private func sendCompletedNotification(courseID: String, assignmentID: String) {
        let route = Route.course(courseID, assignment: assignmentID)
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submitted!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Your files were uploaded and the assignment was submitted successfully.", arguments: nil)
        notificationManager.notify(title: title, body: body, route: route)
    }

    private func submissionFiles(user: KeychainEntry, courseID: String, assignmentID: String) -> [URL] {
        let dir = appGroup.url
            .appendingPathComponent(user.documentsPath, isDirectory: true)
            .appendingPathComponent("courses/\(courseID)/assignments/\(assignmentID)/file-submission", isDirectory: true)
        do {
            return try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants])
        } catch {
            return []
        }
    }
}
