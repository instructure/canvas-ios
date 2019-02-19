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

class StartFileUpload: OperationSet {
    init(backgroundSessionID: String, task: URLSessionTask, database: Persistence, url: URL) {
        super.init()
        let updateFile = DatabaseOperation(database: database) { client in
            let predicate = NSPredicate(format: "%K == %@", #keyPath(FileUpload.url), url as CVarArg)
            if let fileUpload: FileUpload = client.fetch(predicate).first {
                Logger.shared.log("starting file upload with taskID \(task.taskIdentifier)")
                fileUpload.backgroundSessionID = backgroundSessionID
                fileUpload.taskID = task.taskIdentifier
            }
        }

        let resume = BlockOperation {
            task.resume()
        }
        addSequence([updateFile, resume])
    }
}

class UpdateFileUploadProgress: OperationSet {
    init(backgroundSessionID: String, task: URLSessionTask, bytesSent: Int64, expectedToSend: Int64, database: Persistence) {
        let updateFile = DatabaseOperation(database: database) { client in
            let scope = FileUpload.scope(forName: .taskID(backgroundSessionID: backgroundSessionID, taskID: task.taskIdentifier))
            if let fileUpload: FileUpload = client.fetch(scope.predicate).first {
                Logger.shared.log("[file upload progress] sessionID: \(backgroundSessionID), taskID: \(task.taskIdentifier) (\(bytesSent)/\(fileUpload.size))")
                fileUpload.bytesSent = bytesSent
                fileUpload.size = expectedToSend
            }
        }
        super.init(operations: [updateFile])
    }
}

class UpdateFileUploadData: OperationSet {
    struct File: Decodable {
        let id: ID
    }

    init(backgroundSessionID: String, task: URLSessionTask, data: Data, database: Persistence) {
        Logger.shared.log("sessionID: \(backgroundSessionID), taskID: \(task.taskIdentifier)")
        let updateFile = DatabaseOperation(database: database) { client in
            let scope = FileUpload.scope(forName: .taskID(backgroundSessionID: backgroundSessionID, taskID: task.taskIdentifier))
            if let fileUpload: FileUpload = client.fetch(scope.predicate).first {
                do {
                    let decoder = JSONDecoder()
                    let file = try decoder.decode(File.self, from: data)
                    fileUpload.fileID = file.id.value
                    Logger.shared.log("set a fileID! \(file.id.value)")
                } catch {
                    fileUpload.error = error.localizedDescription
                    Logger.shared.error("\(#function) \(error.localizedDescription)")
                    if let submission = fileUpload.submission {
                        let assignment = submission.assignment
                        FileSubmission.sendFailedNotification(courseID: assignment.courseID, assignmentID: assignment.id)
                    }
                }
            } else {
                Logger.shared.error("update data: file upload not found")
            }
        }
        super.init(operations: [updateFile])
    }
}

class CompleteFileUpload: OperationSet {
    let predicate: NSPredicate

    init(predicate: NSPredicate, error: Error?, database: Persistence) {
        self.predicate = predicate
        let updateFile = DatabaseOperation(database: database) { client in
            if let fileUpload: FileUpload = client.fetch(predicate).first {
                if let error = error {
                    fileUpload.error = error.localizedDescription
                    Logger.shared.error("failed to complete file upload \(error.localizedDescription)")
                    if let submission = fileUpload.submission {
                        let assignment = submission.assignment
                        FileSubmission.sendFailedNotification(courseID: assignment.courseID, assignmentID: assignment.id)
                    }
                } else {
                    Logger.shared.log("completed file upload \(predicate)")
                    fileUpload.completed = true
                }
            }
        }
        super.init(operations: [updateFile])
    }

    convenience init(url: URL, error: Error?, database: Persistence) {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(FileUpload.url), url as CVarArg)
        self.init(predicate: predicate, error: error, database: database)
    }

    convenience init(backgroundSessionID: String, task: URLSessionTask, error: Error?, database: Persistence) {
        let scope = FileUpload.scope(forName: .taskID(backgroundSessionID: backgroundSessionID, taskID: task.taskIdentifier))
        self.init(predicate: scope.predicate, error: error, database: database)
    }
}
