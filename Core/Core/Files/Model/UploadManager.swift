//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import CoreData

/// Errors most likely caused by our code.
enum FileUploaderError: Error {
    case urlNotFound
    case invalidTarget
    case fileNotFound
}

open class UploadManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    public static let AssignmentSubmittedNotification = NSNotification.Name(rawValue: "com.instructure.core.assignment-submitted")
    public static var shared = UploadManager(identifier: "com.instructure.core.file-uploads")

    public let identifier: String
    public let sharedContainerIdentifier: String?
    var notificationManager: NotificationManager = .shared
    var process: ProcessManager = ProcessInfo.processInfo
    var environment: AppEnvironment { .shared }
    private var validSession: URLSession?
    private let submissionsStatus = FileSubmissionsStatus()
    var backgroundSession: URLSession {
        if let validSession = validSession {
            return validSession
        }
        let session = createSession()
        validSession = session
        return session
    }
    public var completionHandler: (() -> Void)?

    open var database: NSPersistentContainer {
        return AppEnvironment.shared.globalDatabase
    }
    public var viewContext: NSManagedObjectContext {
        return database.viewContext
    }
    private lazy var context: NSManagedObjectContext = {
        let context = database.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.overwrite
        return context
    }()
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public init(identifier: String, sharedContainerIdentifier: String? = nil) {
        self.identifier = identifier
        self.sharedContainerIdentifier = sharedContainerIdentifier
        super.init()
    }

    @discardableResult
    public func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.sharedContainerIdentifier = sharedContainerIdentifier
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    public func isUploading(completionHandler: @escaping (Bool) -> Void) {
        if let validSession = validSession {
            validSession.getAllTasks { tasks in
                let runningTaskCount = tasks
                    .filter { $0.state == .running }
                    .count
                completionHandler(runningTaskCount > 0)
            }
        } else {
            completionHandler(false)
        }
    }

    public func retry(batchID: String) {
        context.performAndWait {
            let files: [File] = context.fetch(filesPredicate(batchID: batchID))
            let nonCompletedFiles = files.filter { $0.id == nil }

            if nonCompletedFiles.isEmpty {
                // File upload was successful but submission failed, only submission should be retried.
                if let file = files.first, case let .submission(courseID, assignmentID, comment)? = file.context {
                    submit(file: file, courseID: courseID, assignmentID: assignmentID, comment: comment)
                }
            } else {
                for file in nonCompletedFiles {
                    guard let uploadContext = file.context else { continue }
                    upload(file: file, to: uploadContext)
                }
            }
        }
    }

    open func upload(batch batchID: String, to uploadContext: FileUploadContext, callback: (() -> Void)? = nil) {
        context.performAndWait {
            let files: [File] = context.fetch(filesPredicate(batchID: batchID))
            for file in files {
                upload(file: file, to: uploadContext, callback: callback)
            }
        }
    }

    open func upload(url: URL, batchID: String, to uploadContext: FileUploadContext, folderPath: String? = nil, callback: (() -> Void)? = nil) {
        context.performAndWait {
            guard let file = try? add(url: url, batchID: batchID) else { return }
            upload(file: file, to: uploadContext, folderPath: folderPath, callback: callback)
        }
    }

    /**
     - parameters:
        - baseURL: If we upload to a context that is on a different domain we should use that domain instead of the one the user is logged in to. This property overrides the baseURL used in the shared API instance.
     */
    open func upload(file: File,
                     to uploadContext: FileUploadContext,
                     folderPath: String? = nil,
                     baseURL: URL? = nil,
                     callback: (() -> Void)? = nil) {
        Logger.shared.log()
        let objectID = file.objectID
        context.performAndWait {
            guard let file = try? context.existingObject(with: objectID) as? File, let url = file.localFileURL else {
                callback?()
                return
            }
            do {
                file.context = uploadContext
                if let session = environment.currentSession {
                    file.user = File.User(id: session.userID, baseURL: session.baseURL, masquerader: session.masquerader)
                }
                file.uploadError = nil
                file.id = nil
                file.bytesSent = 0
                try context.save()
                Analytics.shared.logEvent("submit_fileupload_info", parameters: ["size": file.size])
                requestFileUpload(fileURL: url,
                                  uploadContext: uploadContext,
                                  fileSize: file.size,
                                  fileObjectID: objectID,
                                  folderPath: folderPath,
                                  baseURL: baseURL,
                                  callback: callback)
            } catch {
                complete(file: file, error: error)
                callback?()
            }
        }
    }

    private func requestFileUpload(fileURL url: URL,
                                   uploadContext: FileUploadContext,
                                   fileSize: Int,
                                   fileObjectID: NSManagedObjectID,
                                   folderPath: String? = nil,
                                   baseURL: URL? = nil,
                                   callback: (() -> Void)? = nil) {
        let body = PostFileUploadTargetRequest.Body(name: url.lastPathComponent, on_duplicate: .rename, parent_folder_path: folderPath, size: fileSize)
        let request = PostFileUploadTargetRequest(context: uploadContext, body: body)

        let api: API = {
            if let baseURL {
                return API(environment.currentSession,
                           baseURL: baseURL)
            } else {
                return environment.api
            }
        }()

        api.makeRequest(request) { response, _, error in
            self.context.performAndWait {
                defer { callback?() }
                guard let file = try? self.context.existingObject(with: fileObjectID) as? File else {
                    return self.notificationManager.sendFailedNotification()
                }
                guard let target = response, error == nil else {
                    return self.complete(file: file, error: error)
                }
                do {
                    file.size = url.lookupFileSize()
                    let request = PostFileUploadRequest(fileURL: url, target: target)
                    let api = API(baseURL: target.upload_url, urlSession: self.backgroundSession)
                    var task = try api.uploadTask(request)
                    file.taskID = UUID.string
                    task.taskID = file.taskID
                    try self.context.save()
                    task.resume()
                } catch let error {
                    self.complete(file: file, error: error)
                }
            }
        }
    }

    // MARK: - URLSession Delegates For Binary Upload

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Logger.shared.log()
        context.performAndWait {
            guard let file = self.file(taskID: task.taskID) else { return }
            file.bytesSent = Int(totalBytesSent)
            file.size = Int(totalBytesExpectedToSend)
            try? context.save()
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Logger.shared.log()
        self.context.performAndWait {
            guard let file = self.file(taskID: task.taskID) else { return }
            if error == nil, case let .submission(courseID, assignmentID, comment)? = file.context {
                self.submit(file: file, courseID: courseID, assignmentID: assignmentID, comment: comment)
                return
            }
            self.complete(file: file, error: error)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Logger.shared.log()
        self.context.performAndWait {
            guard let file = self.file(taskID: dataTask.taskID) else { return }
            do {
                let response = try self.decoder.decode(APIFile.self, from: data)
                File.save(response, to: file, in: self.context)
                try self.context.save()
            } catch {
                self.complete(file: file, error: error)
            }
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        Logger.shared.log()
        validSession = nil
    }

    // MARK: -

    open func cancel(file: File) {
        Logger.shared.log()
        let objectID = file.objectID
        context.performAndWait {
            guard let file = try? context.existingObject(with: objectID) as? File else { return }
            let taskID = file.taskID
            backgroundSession.getAllTasks { tasks in
                tasks.first { $0.taskID == taskID }?.cancel()
            }
            context.delete(file)
            try? context.save()
        }
    }

    open func cancel(batchID: String) {
        Logger.shared.log()
        guard let session = environment.currentSession else { return }
        context.performAndWait {
            let files: [File] = context.fetch(predicate(userID: session.userID, batchID: batchID))
            let taskIDs = files.map { $0.taskID }
            backgroundSession.getAllTasks { tasks in
                for task in tasks where taskIDs.contains(task.taskID) {
                    task.cancel()
                }
            }
            context.delete(files)
            try? context.save()
        }
    }

    /**
     File submissions happen in two phases. The first one is that the app uploads the file binary to a file server and receives a file id in exchange. The second step is that the app uploads this file id as a submission to the assignment.
     If the app is killed before the result of the second step is received then we'll have dangling file references in the DB. This method searches for such files and compares their ids to the ones we received from the API in the assignment. In case of a mismatch we communicate an error but in case the ids are identical we just delete our dangling files.
     */
    public func cleanupDanglingFiles(assignment: Assignment) {
        let assignmentFiles: [File] = viewContext.fetch(filesPredicate(batchID: "assignment-\(assignment.id)"), sortDescriptors: nil)
        let uploadedFiles = assignmentFiles.filter { $0.isUploaded }
        let successfullyUploadedFiles = uploadedFiles.filter { $0.uploadError == nil }
        let successfullyUploadedFileIDs = successfullyUploadedFiles.compactMap({ $0.id })

        if successfullyUploadedFiles.isEmpty || submissionsStatus.isUploadInProgress(fileIDs: successfullyUploadedFileIDs) {
            return
        }

        let submittedFileIDsOnAPI = Set(assignment.submission?.attachments?.compactMap { $0.id } ?? [])

        if Set(successfullyUploadedFileIDs) == submittedFileIDsOnAPI {
            // All files are submitted to the assignment, we can delete our dangling files
            for localFileURL in successfullyUploadedFiles.compactMap({ $0.localFileURL }) {
                try? FileManager.default.removeItem(at: localFileURL)
            }
            viewContext.delete(successfullyUploadedFiles)
        } else {
            viewContext.performAndWait {
                for file in successfullyUploadedFiles {
                    file.id = nil
                    file.taskID = nil
                    file.uploadError = NSLocalizedString("File upload failed. Please cancel your submission and try uploading again.", comment: "")
                }
            }
        }
        try? viewContext.save()
    }

    /**
     If `file` received in parameter has any `batchID` associated, then this method also submits all files sharing the same `batchID`.
     */
    private func submit(file: File, courseID: String, assignmentID: String, comment: String?) {
        Logger.shared.log()
        guard let user = file.user, let session = LoginSession.sessions.first(where: { user == $0 }) else { return }
        var files = [file]
        if let batchID = file.batchID {
            files = context.fetch(predicate(userID: user.id, batchID: batchID))
        }
        guard files.allSatisfy({ $0.isUploaded }) else { return }
        let fileIDs = files.compactMap { $0.id }
        let submission = CreateSubmissionRequest.Body.Submission(text_comment: comment, submission_type: .online_upload, file_ids: fileIDs)
        let requestable = CreateSubmissionRequest(context: .course(courseID), assignmentID: assignmentID, body: .init(submission: submission))
        var task: APITask?
        // This is to make the background task wait until we receive the submission response from the API.
        let semaphore = DispatchSemaphore(value: 0)
        let objectID = file.objectID
        process.performExpiringActivity(reason: "submit assignment") { expired in
            if expired {
                task?.cancel()
            }
            self.submissionsStatus.addTasks(fileIDs: fileIDs)
            task = API(session).makeRequest(requestable) { response, _, error in
                self.context.performAndWait {
                    defer {
                        self.submissionsStatus.removeTasks(fileIDs: fileIDs)
                        semaphore.signal()
                    }
                    guard let file = try? self.context.existingObject(with: objectID) as? File else { return }
                    guard let submission = response, error == nil else {
                        Analytics.shared.logEvent("submit_fileupload_failed", parameters: [
                            "error": error?.localizedDescription ?? "unknown",
                        ])
                        self.complete(file: file, error: error)
                        return
                    }
                    NotificationCenter.default.post(
                        name: UploadManager.AssignmentSubmittedNotification,
                        object: nil,
                        userInfo: ["assignmentID": assignmentID, "submission": submission]
                    )
                    NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
                    if submission.late != true {
                        NotificationCenter.default.post(name: .celebrateSubmission, object: nil, userInfo: [
                            "assignmentID": assignmentID,
                        ])
                    }
                    if let userID = file.userID, let batchID = file.batchID {
                        self.delete(userID: userID, batchID: batchID, in: self.context)
                    }
                    Analytics.shared.logEvent("submit_fileupload_succeeded")
                    self.notificationManager.sendCompletedNotification(courseID: courseID, assignmentID: assignmentID)
                }
            }
            semaphore.wait()
        }
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Logger.shared.log()
        session.finishTasksAndInvalidate()
        completionHandler?()
    }

    func file(taskID: String?) -> File? {
        guard let taskID = taskID else { return nil }
        var file: File?
        context.performAndWait {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(File.taskID), taskID)
            let files: [File] = context.fetch(predicate)
            file = files.first
        }
        return file
    }

    public func complete(file: File, error: Error?) {
        Logger.shared.log()
        if let error = error {
            Logger.shared.error(error)
            Analytics.shared.logEvent("fileupload_failed", parameters: [
                "error": error.localizedDescription,
            ])
        }
        context.performAndWait {
            file.uploadError = error?.localizedDescription
            file.taskID = nil
            if error == nil, let url = file.localFileURL, (try? FileManager.default.removeItem(at: url)) == nil {
                file.localFileURL = nil
            }
            try? context.save()
            if error != nil {
                if case let .submission(courseID, assignmentID, _)? = file.context {
                    notificationManager.sendFailedNotification(courseID: courseID, assignmentID: assignmentID)
                } else {
                    notificationManager.sendFailedNotification()
                }
            }
        }
    }
}
