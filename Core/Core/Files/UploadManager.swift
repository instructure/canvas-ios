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
    public typealias Store = Core.Store<LocalUseCase<File>>

    public static var shared = UploadManager(identifier: "com.instructure.core.file-uploads")

    public let identifier: String
    public let sharedContainerIdentifier: String?
    var notificationManager: NotificationManager = .shared
    var process: ProcessManager = ProcessInfo.processInfo
    var environment: AppEnvironment { .shared }
    private var validSession: URLSession?
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
        return URLSessionAPI.delegateURLSession(configuration, self, nil)
    }

    public func uploadURL(_ url: URL) throws -> URL {
        let dir: URL
        if let containerID = backgroundSession.configuration.sharedContainerIdentifier, let container = URL.sharedContainer(containerID) {
            dir = container
        } else {
            dir = URL.temporaryDirectory
        }
        let newURL = dir
            .appendingPathComponent("uploads", isDirectory: true)
            .appendingPathComponent(UUID.string, isDirectory: true)
            .appendingPathComponent(url.lastPathComponent)
        try url.move(to: newURL)
        return newURL
    }

    public func subscribe(batchID: String, eventHandler: @escaping Store.EventHandler) -> Store {
        let user = environment.currentSession.flatMap { NSPredicate(format: "%K == %@", #keyPath(File.userID), $0.userID) } ?? .all
        let batch = NSPredicate(format: "%K == %@", #keyPath(File.batchID), batchID)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [user, batch])
        let scope = Scope(predicate: predicate, order: [NSSortDescriptor(key: #keyPath(File.size), ascending: true)])
        let useCase = LocalUseCase<File>(scope: scope)
        return Store(env: environment, database: database, useCase: useCase, eventHandler: eventHandler)
    }

    @discardableResult
    public func add(url: URL, batchID: String? = nil) throws -> File {
        let file: File = viewContext.insert()
        let uploadURL = try self.uploadURL(url)
        file.localFileURL = uploadURL
        file.batchID = batchID
        file.size = uploadURL.lookupFileSize()
        if let session = environment.currentSession {
            file.user = File.User(id: session.userID, baseURL: session.baseURL, masquerader: session.masquerader)
        }
        try viewContext.save()
        return file
    }

    open func upload(batch batchID: String, to uploadContext: FileUploadContext, callback: (() -> Void)? = nil) {
        context.performAndWait {
            let user = environment.currentSession.flatMap { NSPredicate(format: "%K == %@", #keyPath(File.userID), $0.userID) } ?? .all
            let batch = NSPredicate(format: "%K == %@", #keyPath(File.batchID), batchID)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [user, batch])
            let files: [File] = context.fetch(predicate)
            for file in files {
                upload(file: file, to: uploadContext, callback: callback)
            }
        }
    }

    open func upload(url: URL, batchID: String? = nil, to uploadContext: FileUploadContext, folderPath: String? = nil, callback: (() -> Void)? = nil) {
        context.performAndWait {
            guard let file = try? add(url: url, batchID: batchID) else { return }
            upload(file: file, to: uploadContext, folderPath: folderPath, callback: callback)
        }
    }

    open func upload(file: File, to uploadContext: FileUploadContext, folderPath: String? = nil, callback: (() -> Void)? = nil) {
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
                let body = PostFileUploadTargetRequest.Body(name: url.lastPathComponent, on_duplicate: .rename, parent_folder_path: folderPath, size: file.size)
                let request = PostFileUploadTargetRequest(context: uploadContext, body: body)
                environment.api.makeRequest(request) { response, _, error in
                    self.context.performAndWait {
                        defer { callback?() }
                        guard let file = try? self.context.existingObject(with: objectID) as? File else {
                            return self.sendFailedNotification()
                        }
                        guard let target = response, error == nil else {
                            return self.complete(file: file, error: error)
                        }
                        do {
                            file.size = url.lookupFileSize()
                            let request = PostFileUploadRequest(fileURL: url, target: target)
                            let api = URLSessionAPI(loginSession: nil, baseURL: target.upload_url, urlSession: self.backgroundSession)
                            let task = try api.uploadTask(request)
                            file.taskID = UUID.string
                            task.taskDescription = file.taskID
                            try self.context.save()
                            task.resume()
                        } catch let error {
                            self.complete(file: file, error: error)
                        }
                    }
                }
            } catch {
                complete(file: file, error: error)
                callback?()
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Logger.shared.log()
        context.performAndWait {
            guard let file = self.file(taskID: task.taskDescription) else { return }
            file.bytesSent = Int(totalBytesSent)
            file.size = Int(totalBytesExpectedToSend)
            try? context.save()
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Logger.shared.log()
        self.context.performAndWait {
            guard let file = self.file(taskID: task.taskDescription) else { return }
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
            guard let file = self.file(taskID: dataTask.taskDescription) else { return }
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

    func delete(userID: String, batchID: String) {
        Logger.shared.log()
        context.performAndWait {
            let files: [File] = context.fetch(predicate(userID: userID, batchID: batchID))
            for file in files {
                guard let url = file.localFileURL else { continue }
                try? FileManager.default.removeItem(at: url)
            }
            context.delete(files)
            try? context.save()
        }
    }

    open func cancel(file: File) {
        Logger.shared.log()
        let objectID = file.objectID
        context.performAndWait {
            guard let file = try? context.existingObject(with: objectID) as? File else { return }
            let taskID = file.taskID
            backgroundSession.getAllTasks { tasks in
                tasks.first { $0.taskDescription == taskID }?.cancel()
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
                for task in tasks {
                    if taskIDs.contains(task.taskDescription) {
                        task.cancel()
                    }
                }
            }
            context.delete(files)
            try? context.save()
        }
    }

    private func predicate(userID: String, batchID: String) -> NSPredicate {
        let user = NSPredicate(format: "%K == %@", #keyPath(File.userID), userID)
        let batch = NSPredicate(format: "%K == %@", #keyPath(File.batchID), batchID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [user, batch])
    }

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
        var task: URLSessionTask?
        let semaphore = DispatchSemaphore(value: 0)
        let objectID = file.objectID
        process.performExpiringActivity(withReason: "submit assignment") { expired in
            if expired {
                task?.cancel()
            }
            let api = URLSessionAPI(loginSession: session)
            task = api.makeRequest(requestable) { response, _, error in
                self.context.performAndWait {
                    defer { semaphore.signal() }
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
                    if !submission.late {
                        NotificationCenter.default.post(name: .celebrateSubmission, object: nil, userInfo: [
                            "assignmentID": assignmentID,
                        ])
                    }
                    if let userID = file.userID, let batchID = file.batchID {
                        self.delete(userID: userID, batchID: batchID)
                    }
                    Analytics.shared.logEvent("submit_fileupload_succeeded")
                    self.sendCompletedNotification(courseID: courseID, assignmentID: assignmentID)
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
                    sendFailedNotification(courseID: courseID, assignmentID: assignmentID)
                } else {
                    sendFailedNotification()
                }
            }
        }
    }

    private func sendFailedNotification(courseID: String, assignmentID: String) {
        Logger.shared.log()
        let identifier = "failed-submission-\(courseID)-\(assignmentID)"
        let route = "/courses/\(courseID)/assignments/\(assignmentID)"
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)
        notificationManager.notify(identifier: identifier, title: title, body: body, route: route)
    }

    private func sendCompletedNotification(courseID: String, assignmentID: String) {
        Logger.shared.log()
        let identifier = "completed-submission-\(courseID)-\(assignmentID)"
        let route = "/courses/\(courseID)/assignments/\(assignmentID)"
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submitted!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Your files were uploaded and the assignment was submitted successfully.", arguments: nil)
        notificationManager.notify(identifier: identifier, title: title, body: body, route: route)
    }

    public func sendFailedNotification() {
        let title = NSString.localizedUserNotificationString(forKey: "Failed to send files!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with uploading files.", arguments: nil)
        notificationManager.notify(identifier: "upload-manager", title: title, body: body, route: nil)
    }
}
