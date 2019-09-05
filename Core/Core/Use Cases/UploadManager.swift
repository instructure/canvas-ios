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

enum UploadStep: String {
    case target, upload, submit
    case refreshTarget, refreshSubmit
}

extension URLSessionTask {
    var uploadStep: UploadStep? {
        get {
            guard let desc = taskDescription else { return nil }
            return UploadStep(rawValue: desc)
        }
        set { taskDescription = newValue?.rawValue }
    }
}

open class UploadManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    public static let AssignmentSubmittedNotification = NSNotification.Name(rawValue: "com.instructure.core.assignment-submitted")
    public typealias Store = Core.Store<LocalUseCase<File>>

    public static var shared = UploadManager()

    var notificationManager: NotificationManager = .shared
    private var validSession: URLSession?
    var backgroundSession: URLSession {
        if let validSession = validSession {
            return validSession
        }
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.instructure.core.file-uploads")
        configuration.sharedContainerIdentifier = Bundle.main.appGroupID()
        let session = URLSessionAPI.delegateURLSession(configuration, self, nil)
        validSession = session
        return session
    }
    public var completionHandler: (() -> Void)?

    public let database = NSPersistentContainer.shared
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

    public func subscribe(environment: AppEnvironment = .shared, batchID: String, eventHandler: @escaping Store.EventHandler) -> Store {
        let user = environment.currentSession.flatMap { NSPredicate(format: "%K == %@", #keyPath(File.userID), $0.userID) } ?? .all
        let batch = NSPredicate(format: "%K == %@", #keyPath(File.batchID), batchID)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [user, batch])
        let scope = Scope(predicate: predicate, order: [NSSortDescriptor(key: #keyPath(File.size), ascending: true)])
        let useCase = LocalUseCase<File>(scope: scope)
        return Store(env: environment, database: database, useCase: useCase, eventHandler: eventHandler)
    }

    @discardableResult
    open func add(environment: AppEnvironment = .shared, url: URL, batchID: String? = nil) -> NSManagedObjectID? {
        var objectID: NSManagedObjectID?
        context.performAndWait {
            do {
                let file: File = context.insert()
                file.localFileURL = try uploadURL(url)
                file.batchID = batchID
                file.size = url.lookupFileSize()
                if let session = environment.currentSession {
                    file.user = File.User(id: session.userID, baseURL: session.baseURL, masquerader: session.masquerader)
                }
                try context.save()
                objectID = file.objectID
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        return objectID
    }

    open func upload(environment: AppEnvironment = .shared, batch batchID: String, to uploadContext: FileUploadContext) {
        context.performAndWait {
            let user = environment.currentSession.flatMap { NSPredicate(format: "%K == %@", #keyPath(File.userID), $0.userID) } ?? .all
            let batch = NSPredicate(format: "%K == %@", #keyPath(File.batchID), batchID)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [user, batch])
            let files: [File] = context.fetch(predicate)
            for file in files {
                upload(environment: environment, file: file, to: uploadContext)
            }
        }
    }

    open func upload(environment: AppEnvironment = .shared, url: URL, batchID: String? = nil, to uploadContext: FileUploadContext) {
        context.performAndWait {
            guard let objectID = add(environment: environment, url: url, batchID: batchID) else { return }
            guard let file = try? context.existingObject(with: objectID) as? File else { return }
            upload(environment: environment, file: file, to: uploadContext)
        }
    }

    /// File is assumed to exist in `NSPersistentContainer.shared`
    /// Use `UploadManager.shared.uploadURL(_:)` as the file's `localFileURL`
    /// Or (preferably) use `UploadManager.shared.upload(url:)`
    open func upload(environment: AppEnvironment = .shared, file: File, to uploadContext: FileUploadContext) {
        guard let session = environment.currentSession else {
            assertionFailure("Expected a currentSession")
            return
        }
        let objectID = file.objectID
        context.performAndWait {
            guard let file = try? context.existingObject(with: objectID) as? File else { return }
            getTarget(file: file, session: session, uploadContext: uploadContext)
        }
    }

    private func getTarget(file: File, session: LoginSession, uploadContext: FileUploadContext) {
        guard let url = file.localFileURL else {
            assertionFailure("File should have  localFileURL")
            return
        }
        do {
            let body = PostFileUploadTargetRequest.Body(name: url.lastPathComponent, on_duplicate: .rename, parent_folder_id: nil, size: file.size)
            let requestable = PostFileUploadTargetRequest(context: uploadContext, body: body)
            let request = try requestable.urlRequest(relativeTo: session.baseURL, accessToken: session.accessToken, actAsUserID: session.actAsUserID)
            let task = backgroundSession.dataTask(with: request)
            file.localFileURL = url
            task.uploadStep = .target
            file.taskID = task.taskIdentifier
            file.context = uploadContext
            file.uploadError = nil
            file.id = nil
            file.target = nil
            file.bytesSent = 0
            file.submitData = nil
            file.targetData = nil
            file.uploadData = nil
            try context.save()
            task.resume()
        } catch {
            complete(file: file, error: error)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        context.performAndWait {
            guard
                let step = dataTask.uploadStep,
                let file = self.file(taskID: dataTask.taskIdentifier)
            else { return }
            do {
                switch step {
                case .target:
                    file.targetData = (file.targetData ?? Data()) + data
                case .upload:
                    file.uploadData = (file.uploadData ?? Data()) + data
                case .submit:
                    file.submitData = (file.submitData ?? Data()) + data
                case .refreshTarget, .refreshSubmit:
                    file.refreshData = (file.refreshData ?? Data()) + data
                }
                try context.save()
            } catch {
                complete(file: file, error: APIError.from(data: data, response: nil, error: error))
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        context.performAndWait {
            guard let step = task.uploadStep, let file = self.file(taskID: task.taskIdentifier) else { return }
            switch step {
            case .upload:
                file.bytesSent = Int(totalBytesSent)
                file.size = Int(totalBytesExpectedToSend)
            default: break
            }
            try? context.save()
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        context.performAndWait {
            guard let step = task.uploadStep else { return }
            if error != nil, task.response?.isUnauthorized == true, step != .refreshTarget, step != .refreshSubmit {
                refreshToken(task: task, error: error)
                return
            }
            switch step {
            case .target:
                completeTarget(task: task, error: error)
            case .upload:
                completeUpload(task: task, error: error)
            case .submit:
                completeSubmit(task: task, error: error)
            case .refreshTarget, .refreshSubmit:
                completeRefresh(task: task, error: error)
            }
        }
    }

    func completeRefresh(task: URLSessionTask, error: Error?) {
        context.performAndWait {
            guard let file = self.file(taskID: task.taskIdentifier) else {
                return
            }
            guard error == nil else {
                complete(file: file, error: error)
                return
            }
            guard
                let user = file.user,
                let session = LoginSession.sessions.first(where: { user == $0 }),
                let data = file.refreshData,
                let token = try? decoder.decode(APIOAuthToken.self, from: data)
            else {
                return
            }
            LoginSession.add(session.refresh(accessToken: token.access_token))
            switch task.uploadStep {
            case .refreshTarget?:
                retryTarget(task: task, error: error)
            case .refreshSubmit?:
                retrySubmit(task: task, error: error)
            default: break
            }
        }
    }

    func refreshToken(task: URLSessionTask, error: Error?) {
        context.performAndWait {
            guard let file = self.file(taskID: task.taskIdentifier) else {
                return
            }
            guard
                let step = task.uploadStep,
                let user = file.user,
                let session = LoginSession.sessions.first(where: { user == $0 }),
                let refreshToken = session.refreshToken,
                let clientID = session.clientID,
                let clientSecret = session.clientSecret
            else {
                complete(file: file, error: error)
                return
            }
            do {
                let client = APIVerifyClient(authorized: true, base_url: session.baseURL, client_id: clientID, client_secret: clientSecret)
                let requestable = PostLoginOAuthRequest(client: client, refreshToken: refreshToken)
                let request = try requestable.urlRequest(relativeTo: user.baseURL, accessToken: session.accessToken, actAsUserID: session.actAsUserID)
                let task = backgroundSession.dataTask(with: request)
                switch step {
                case .target:
                    task.uploadStep = .refreshTarget
                case .submit:
                    task.uploadStep = .refreshSubmit
                case .refreshSubmit, .refreshTarget, .upload:
                    break
                }
                file.taskID = task.taskIdentifier
                try context.save()
                task.resume()
            } catch {
                complete(file: file, error: error)
            }
        }
    }

    func retryTarget(task: URLSessionTask, error: Error?) {
        context.performAndWait {
            guard
                let file = self.file(taskID: task.taskIdentifier),
                let uploadContext = file.context,
                let user = file.user,
                let session = LoginSession.sessions.first(where: { user == $0 })
            else {
                return
            }
            guard error == nil else {
                complete(file: file, error: error)
                return
            }
            getTarget(file: file, session: session, uploadContext: uploadContext)
        }
    }

    func retrySubmit(task: URLSessionTask, error: Error?) {
        context.performAndWait {
            guard
                let file = self.file(taskID: task.taskIdentifier),
                case let .submission(courseID, assignmentID, comment)? = file.context
            else {
                return
            }
            if error != nil {
                complete(file: file, error: error)
                return
            }
            submit(file: file, courseID: courseID, assignmentID: assignmentID, comment: comment)
        }
    }

    func completeUpload(task: URLSessionTask, error: Error?) {
        context.performAndWait {
            guard let file = self.file(taskID: task.taskIdentifier) else { return }
            if error != nil,
                let response = task.response as? HTTPURLResponse,
                response.statusCode == 201,
                let location = response.allHeaderFields[HttpHeader.location] as? String,
                let url = URL(string: location),
                let user = file.user,
                let session = LoginSession.sessions.first(where: { user == $0 }) {
                do {
                    // Upload failed with a 201 so fetch the file using the url in the Location header
                    var request = URLRequest(url: url)
                    if let token = session.accessToken {
                        request.setValue("Bearer \(token)", forHTTPHeaderField: HttpHeader.authorization)
                    }
                    request.setValue("application/json+canvas-string-ids", forHTTPHeaderField: HttpHeader.accept)
                    let task = backgroundSession.dataTask(with: request)
                    task.uploadStep = .upload
                    file.taskID = task.taskIdentifier
                    try context.save()
                    task.resume()
                } catch {
                    complete(file: file, error: error)
                }
                return
            }

            guard let data = file.uploadData else {
                complete(file: file, error: error)
                return
            }
            do {
                let result = try decoder.decode(APIFile.self, from: data)
                file.update(fromAPIModel: result)
                try context.save()
                if case let .submission(courseID, assignmentID, comment)? = file.context, error == nil {
                    submit(file: file, courseID: courseID, assignmentID: assignmentID, comment: comment)
                    return
                }
                complete(file: file, error: error)
            } catch {
                complete(file: file, error: APIError.from(data: data, response: nil, error: error))
            }
        }
    }

    func completeTarget(task: URLSessionTask, error: Error?) {
        context.performAndWait {
            guard let file = self.file(taskID: task.taskIdentifier) else { return }
            guard let data = file.targetData, let url = file.localFileURL else { return }
            guard error == nil else {
                complete(file: file, error: error)
                return
            }
            do {
                let target = try decoder.decode(FileUploadTarget.self, from: data)
                let request = PostFileUploadRequest(fileURL: url, target: target)
                let api = URLSessionAPI(baseURL: target.upload_url, urlSession: backgroundSession)
                let task = try api.uploadTask(request)
                task.uploadStep = .upload
                file.taskID = task.taskIdentifier
                file.target = target
                try context.save()
                task.resume()
            } catch {
                complete(file: file, error: error)
            }
        }
    }

    func completeSubmit(task: URLSessionTask, error: Error?) {
        context.performAndWait {
            guard let file = self.file(taskID: task.taskIdentifier) else { return }
            guard case let .submission(courseID, assignmentID, _)? = file.context else { return }
            if error == nil, let userID = file.userID, let batchID = file.batchID {
                sendCompletedNotification(courseID: courseID, assignmentID: assignmentID)
                if let data = file.submitData, let submission = try? decoder.decode(APISubmission.self, from: data) {
                    NotificationCenter.default.post(
                        name: UploadManager.AssignmentSubmittedNotification,
                        object: nil,
                        userInfo: ["assignmentID": assignmentID, "submission": submission]
                    )
                }
                delete(userID: userID, batchID: batchID)
                Analytics.shared.logEvent("submit_fileupload_succeeded")
            } else {
                sendFailedNotification(courseID: courseID, assignmentID: assignmentID)
                Analytics.shared.logEvent("submit_fileupload_failed", parameters: [
                    "error": error?.localizedDescription ?? "unknown",
                ])
            }
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        validSession = nil
    }

    func delete(userID: String, batchID: String) {
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
        let objectID = file.objectID
        context.performAndWait {
            guard let file = try? context.existingObject(with: objectID) as? File, let taskID = file.taskID else { return }
            backgroundSession.getAllTasks { tasks in
                tasks.first { $0.taskIdentifier == taskID }?.cancel()
            }
            context.delete(file)
            try? context.save()
        }
    }

    open func cancel(environment: AppEnvironment = .shared, batchID: String) {
        guard let session = environment.currentSession else { return }
        context.performAndWait {
            let files: [File] = context.fetch(predicate(userID: session.userID, batchID: batchID))
            let taskIDs = files.compactMap { $0.taskID }
            backgroundSession.getAllTasks { tasks in
                for task in tasks {
                    if taskIDs.contains(task.taskIdentifier) {
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
        guard let user = file.user, let session = LoginSession.sessions.first(where: { user == $0 }) else { return }
        var files = [file]
        if let batchID = file.batchID {
            files = context.fetch(predicate(userID: user.id, batchID: batchID))
        }
        guard files.allSatisfy({ $0.isUploaded }) else { return }
        let fileIDs = files.compactMap { $0.id }
        let submission = CreateSubmissionRequest.Body.Submission(text_comment: comment, submission_type: .online_upload, file_ids: fileIDs)
        let requestable = CreateSubmissionRequest(context: ContextModel(.course, id: courseID), assignmentID: assignmentID, body: .init(submission: submission))
        do {
            let request = try requestable.urlRequest(relativeTo: session.baseURL, accessToken: session.accessToken, actAsUserID: session.actAsUserID)
            let task = backgroundSession.dataTask(with: request)
            task.uploadStep = .submit
            file.taskID = task.taskIdentifier
            try context.save()
            task.resume()
        } catch {
            complete(file: file, error: error)
        }
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.finishTasksAndInvalidate()
        validSession = nil
        completionHandler?()
    }

    func file(taskID: Int) -> File? {
        var file: File?
        context.performAndWait {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(File.taskIDRaw), NSNumber(value: taskID))
            let files: [File] = context.fetch(predicate)
            file = files.first
        }
        return file
    }

    func complete(file: File, error: Error?) {
        context.performAndWait {
            file.uploadError = error?.localizedDescription
            file.taskID = nil
            if error == nil, let url = file.localFileURL, (try? FileManager.default.removeItem(at: url)) == nil {
                file.localFileURL = nil
            }
            try? context.save()
            if case let .submission(courseID, assignmentID, _)? = file.context {
                sendFailedNotification(courseID: courseID, assignmentID: assignmentID)
            }
        }
    }

    private func sendFailedNotification(courseID: String, assignmentID: String) {
        let identifier = "failed-submission-\(courseID)-\(assignmentID)"
        let route = Route.course(courseID, assignment: assignmentID)
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)
        notificationManager.notify(identifier: identifier, title: title, body: body, route: route)
    }

    private func sendCompletedNotification(courseID: String, assignmentID: String) {
        let identifier = "completed-submission-\(courseID)-\(assignmentID)"
        let route = Route.course(courseID, assignment: assignmentID)
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submitted!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Your files were uploaded and the assignment was submitted successfully.", arguments: nil)
        notificationManager.notify(identifier: identifier, title: title, body: body, route: route)
    }
}
