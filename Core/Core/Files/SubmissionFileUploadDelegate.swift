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

    public init(appGroup: AppGroup) {
        self.appGroup = appGroup
    }

    public func fileUploader(_ fileUploader: FileUploader, finishedUpload url: URL) {
        fileUploader.database.perform { context in
            guard let fileUpload: FileUpload = context.first(where: #keyPath(FileUpload.url), equals: url as CVarArg) else {
                return
            }
            guard let user = Keychain.entries.first(where: { $0.hashValue == fileUpload.user }) else {
                return
            }
            guard let target = fileUpload.context else {
                return
            }
            switch target {
            case let .submission(courseID: courseID, assignmentID: assignmentID):
                Logger.shared.log("File submission upload finished")
                 let contextMatch = NSPredicate(format: "%K == %@", #keyPath(FileUpload.contextRaw), target.rawValue)
                let userMatch = NSPredicate(format: "%K == %@", #keyPath(FileUpload.userRaw), NSNumber(value: user.hashValue))
                 let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [contextMatch, userMatch])
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
        Logger.shared.log("Submitting \(fileIDs.count) files to assignment \(assignmentID)")
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
                // TODO: Send push notification
                print(error)
            }
            if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 201 {
                Logger.shared.log("\(fileIDs.count) files submitted!")
                do {
                    // Delete all the files
                    let submissionFilesDirectory = self.appGroup.url
                        .appendingPathComponent(user.documentsPath, isDirectory: true)
                        .appendingPathComponent("courses/\(courseID)/assignments/\(assignmentID)/file-submission", isDirectory: true)
                    let submissionFiles = try FileManager.default.contentsOfDirectory(at: submissionFilesDirectory, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants])
                    for file in submissionFiles {
                        try FileManager.default.removeItem(at: file)
                        Logger.shared.log("Removed local file submissions")
                    }
                } catch {
                    Logger.shared.error(error.localizedDescription)
                }
            } else {
                Logger.shared.error("Unexpected file submission response")
            }
        }
    }
}
