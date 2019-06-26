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
import CoreData

/// Errors most likely caused by our code.
enum FileUploaderError: Error {
    case urlNotFound
    case invalidTarget
    case fileNotFound
}

public class UploadManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    public static let AssignmentSubmittedNotification = NSNotification.Name(rawValue: "com.instructure.core.assignment-submitted")
    public typealias Store = Core.Store<LocalUseCase<File>>

    enum Step: String {
        case target, upload, submit
    }

    public static let shared = UploadManager()

    let database = NSPersistentContainer.shared
    var notificationManager: NotificationManager = .shared
    lazy var context = database.newBackgroundContext()
    private var validSession: URLSession?
    var backgroundSession: URLSession {
        if let validSession = validSession {
            return validSession
        }
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.instructure.core.file-uploads")
        configuration.sharedContainerIdentifier = Bundle.main.appGroupID()
        let session = URLSessionAPI.delegateURLSession(configuration, self)
        validSession = session
        return session
    }
    public var completionHandler: (() -> Void)?

    public func subscribe(environment: AppEnvironment = .shared, batchID: String, eventHandler: @escaping Store.EventHandler) -> Store {
        let user = environment.currentSession.flatMap { NSPredicate(format: "%K == %@", #keyPath(File.userID), $0.userID) } ?? .all
        let batch = NSPredicate(format: "%K == %@", #keyPath(File.batchID), batchID)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [user, batch])
        let scope = Scope(predicate: predicate, order: [NSSortDescriptor(key: #keyPath(File.size), ascending: true)])
        let useCase = LocalUseCase<File>(scope: scope)
        return Store(env: environment, database: database, useCase: useCase, eventHandler: eventHandler)
    }

    @discardableResult
    public func add(environment: AppEnvironment = .shared, url: URL, batchID: String? = nil) -> NSManagedObjectID {
        var objectID: NSManagedObjectID!
        context.performAndWait {
            let file: File = context.insert()
            file.localFileURL = url
            file.batchID = batchID
            file.size = url.lookupFileSize()
            if let session = environment.currentSession {
                file.user = File.User(id: session.userID, baseURL: session.baseURL, actAsUserID: session.actAsUserID)
            }
            objectID = file.objectID
            try? context.save()
        }
        return objectID
    }

    public func upload(environment: AppEnvironment = .shared, batch batchID: String, to uploadContext: FileUploadContext) {
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

    public func upload(environment: AppEnvironment = .shared, url: URL, batchID: String? = nil, to uploadContext: FileUploadContext) {
        let objectID = add(environment: environment, url: url, batchID: batchID)
        context.performAndWait {
            guard let file = context.object(with: objectID) as? File else { return }
            upload(environment: environment, file: file, to: uploadContext)
        }
    }

    /// File must exist in `NSPersistentContainer.shared`
    public func upload(environment: AppEnvironment = .shared, file: File, to uploadContext: FileUploadContext) {
        let objectID = file.objectID
        context.performAndWait {
            guard let file = context.object(with: objectID) as? File, let url = file.localFileURL else { return }
            do {
                let api = environment.api
                let body = PostFileUploadTargetRequest.Body(name: url.lastPathComponent, on_duplicate: .rename, parent_folder_id: nil, size: file.size)
                let requestable = PostFileUploadTargetRequest(context: uploadContext, body: body)
                let request = try requestable.urlRequest(relativeTo: api.baseURL, accessToken: api.accessToken, actAsUserID: api.actAsUserID)
                let task = backgroundSession.dataTask(with: request)
                task.taskDescription = Step.target.rawValue
                file.taskID = task.taskIdentifier
                file.context = uploadContext
                file.uploadError = nil
                file.id = nil
                file.target = nil
                file.bytesSent = 0
                try context.save()
                task.resume()
            } catch {
                complete(file: file, error: error)
            }
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        context.performAndWait {
            guard
                let description = dataTask.taskDescription,
                let step = Step(rawValue: description),
                let file = self.file(taskID: dataTask.taskIdentifier)
            else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                switch step {
                case .target:
                    let target = try decoder.decode(FileUploadTarget.self, from: data)
                    file.target = target
                case .upload:
                    let result = try decoder.decode(APIFile.self, from: data)
                    file.update(fromAPIModel: result)
                case .submit:
                    guard case let .submission(courseID: _, assignmentID: assignmentID)? = file.context else { break }
                    let submission = try decoder.decode(APISubmission.self, from: data)
                    NotificationCenter.default.post(
                        name: UploadManager.AssignmentSubmittedNotification,
                        object: nil,
                        userInfo: ["assignmentID": assignmentID, "submission": submission]
                    )
                }
                try context.save()
            } catch {
                #if DEBUG
                print(String(data: data, encoding: .utf8) ?? "", error)
                #endif
                complete(file: file, error: error)
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Logger.shared.log()
        context.performAndWait {
            guard let file = self.file(taskID: task.taskIdentifier) else { return }
            file.bytesSent = Int(totalBytesSent)
            file.size = Int(totalBytesExpectedToSend)
            try? context.save()
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Logger.shared.log()
        context.performAndWait {
            guard
                let description = task.taskDescription,
                let step = Step(rawValue: description),
                let file = self.file(taskID: task.taskIdentifier)
            else { return }
            switch step {
            case .upload:
                if case let .submission(courseID: courseID, assignmentID: assignmentID)? = file.context, error == nil {
                    submit(file: file, courseID: courseID, assignmentID: assignmentID)
                    return
                }
                complete(file: file, error: error)
            case .submit:
                complete(file: file, error: error)
                if error == nil, let userID = file.userID, let batchID = file.batchID {
                    delete(userID: userID, batchID: batchID)
                }
            case .target:
                guard let target = file.target, let url = file.localFileURL else { return }
                let request = PostFileUploadRequest(fileURL: url, target: target)
                let api = URLSessionAPI(accessToken: nil, actAsUserID: file.user?.actAsUserID, baseURL: target.upload_url, urlSession: backgroundSession)
                do {
                    let task = try api.uploadTask(request)
                    task.taskDescription = Step.upload.rawValue
                    file.taskID = task.taskIdentifier
                    try context.save()
                    task.resume()
                } catch {
                    complete(file: file, error: error)
                }
            }
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        validSession = nil
    }

    func delete(userID: String, batchID: String) {
        context.performAndWait {
            let files: [File] = context.fetch(predicate(userID: userID, batchID: batchID))
            context.delete(files)
            try? context.save()
        }
    }

    public func delete(environment: AppEnvironment = .shared, batchID: String) {
        guard let session = environment.currentSession else { return }
        delete(userID: session.userID, batchID: batchID)
    }

    public func cancel(environment: AppEnvironment = .shared, batchID: String) {
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

    private func submit(file: File, courseID: String, assignmentID: String) {
        Logger.shared.log()
        guard let user = file.user, let session = Keychain.entries.first(where: { user == $0 }) else { return }
        var files = [file]
        if let batchID = file.batchID {
            files = context.fetch(predicate(userID: user.id, batchID: batchID))
        }
        guard files.allSatisfy({ $0.isUploaded }) else { return }
        let fileIDs = files.compactMap { $0.id }
        let submission = CreateSubmissionRequest.Body.Submission(submission_type: .online_upload, file_ids: fileIDs)
        let requestable = CreateSubmissionRequest(context: ContextModel(.course, id: courseID), assignmentID: assignmentID, body: .init(submission: submission))
        do {
            let request = try requestable.urlRequest(relativeTo: session.baseURL, accessToken: session.accessToken, actAsUserID: session.actAsUserID)
            let task = backgroundSession.dataTask(with: request)
            task.taskDescription = Step.submit.rawValue
            file.taskID = task.taskIdentifier
            try context.save()
            task.resume()
        } catch {
            complete(file: file, error: error)
        }
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        completionHandler?()
        session.finishTasksAndInvalidate()
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
        Logger.shared.log(error?.localizedDescription ?? #function)
        context.performAndWait {
            file.uploadError = error?.localizedDescription
            file.taskID = nil
            try? context.save()

            if case let .submission(courseID: courseID, assignmentID: assignmentID)? = file.context {
                if error == nil {
                    sendCompletedNotification(courseID: courseID, assignmentID: assignmentID)
                } else {
                    sendFailedNotification(courseID: courseID, assignmentID: assignmentID)
                }
            }
        }
    }

    private func sendFailedNotification(courseID: String, assignmentID: String) {
        Logger.shared.log()
        let identifier = "failed-submission-\(courseID)-\(assignmentID)"
        let route = Route.course(courseID, assignment: assignmentID)
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)
        notificationManager.notify(identifier: identifier, title: title, body: body, route: route)
    }

    private func sendCompletedNotification(courseID: String, assignmentID: String) {
        Logger.shared.log()
        let identifier = "completed-submission-\(courseID)-\(assignmentID)"
        let route = Route.course(courseID, assignment: assignmentID)
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submitted!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Your files were uploaded and the assignment was submitted successfully.", arguments: nil)
        notificationManager.notify(identifier: identifier, title: title, body: body, route: route)
    }
}
