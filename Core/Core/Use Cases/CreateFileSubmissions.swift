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

public class CreateFileSubmissions: OperationSet {
    let env: AppEnvironment

    public init(env: AppEnvironment, userID: String) {
        self.env = env
        super.init()
        let operation = DatabaseOperation(database: env.database) { [weak self] client in
            guard let self = self else { return }
            let noError = NSPredicate(format: "%K == nil", #keyPath(FileSubmission.error))
            let notSubmitted = NSPredicate(format: "%K == false", #keyPath(FileSubmission.submitted))
            let thisUser = NSPredicate(format: "%K == %@", #keyPath(FileSubmission.userID), userID)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [noError, notSubmitted, thisUser])

            let fileSubmissions: [FileSubmission] = client.fetch(predicate)
            env.logger.log("unsubmitted submissions: \(fileSubmissions.count)")
            for fileSubmission in fileSubmissions {
                if let next = fileSubmission.next {
                    self.upload(url: next.url)
                } else if fileSubmission.readyToSubmit {
                    self.submit(fileSubmission: fileSubmission)
                } else {
                    let assignment = fileSubmission.assignment
                    FileSubmission.sendFailedNotification(courseID: assignment.courseID, assignmentID: assignment.id)
                    env.logger.log("fileSubmission in an unknown state")
                }
            }
        }
        addOperation(operation)
    }

    func upload(url: URL) {
        env.logger.log("uploading next")
        let uploadFile = UploadFile(env: env, file: url)
        addOperation(uploadFile)
    }

    func submit(fileSubmission: FileSubmission) {
        env.logger.log("submitting file submission")
        let assignmentID = fileSubmission.assignment.id

        let context = ContextModel(.course, id: fileSubmission.assignment.courseID)
        let createSubmission = CreateSubmission(
            context: context,
            assignmentID: fileSubmission.assignment.id,
            userID: fileSubmission.userID,
            textComment: fileSubmission.comment,
            submissionType: .online_upload,
            fileIDs: fileSubmission.fileUploads?.compactMap { $0.fileID },
            env: env
        )

        let updateFileSubmission = DatabaseOperation(database: env.database) { [weak createSubmission, weak self] client in
            let predicate = Assignment.scope(forName: .details(assignmentID)).predicate
            if let assignment: Assignment = client.fetch(predicate).first {
                if let fileSubmission = assignment.fileSubmission, let createSubmission = createSubmission {
                    if let error = createSubmission.errors.first {
                        fileSubmission.error = error.localizedDescription
                        FileSubmission.sendFailedNotification(courseID: assignment.courseID, assignmentID: assignment.id)
                        self?.env.logger.error("failed to update file submission \(error.localizedDescription)")
                    } else {
                        fileSubmission.submitted = true
                        FileSubmission.sendCompletedNotification(courseID: assignment.courseID, assignmentID: assignment.id)
                        self?.env.logger.log("successfully submitted file submission")
                    }
                }
            }
        }
        updateFileSubmission.addDependency(createSubmission)

        addOperations([createSubmission, updateFileSubmission])
    }
}
