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

public protocol FileUploaderDelegate {
    func fileUploader(_ fileUploader: FileUploader, finishedUploadingFile file: File, inContext context: NSManagedObjectContext)
}

public class FileUploader: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    fileprivate struct Session: Codable {
        let bundleID: String
        let appGroup: AppGroup?
        let userID: String
        let baseURL: URL
        let actAsUserID: String?

        init(bundleID: String, appGroup: AppGroup?, userID: String, baseURL: URL, actAsUserID: String?) {
            self.bundleID = bundleID
            self.appGroup = appGroup
            self.userID = userID
            self.baseURL = baseURL
            self.actAsUserID = actAsUserID
        }

        init?(string: String) {
            guard let data = Data(base64Encoded: string) else {
                return nil
            }
            do {
                let decoder = JSONDecoder()
                self = try decoder.decode(Session.self, from: data)
            } catch {
                return nil
            }
        }

        var identifier: String {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(self)
                return data.base64EncodedString()
            } catch {
                assertionFailure("failed to encode background identifier")
                return ""
            }
        }
    }

    public let api: API
    public let database: NSPersistentContainer
    public var notificationManager: NotificationManager = .shared
    var backgroundSession: URLSession!
    lazy var backgroundAPI: API = URLSessionAPI(urlSession: backgroundSession)

    lazy var taskContext: NSManagedObjectContext = database.newBackgroundContext()
    lazy var submissionContext: NSManagedObjectContext = database.newBackgroundContext()

    /// Completion handler that should be called once all background tasks have finished.
    ///
    /// See UIApplicationDelegate.application(application:handleEventsForBackgroundURLSession:completionHandler:)
    public var completionHandler: (() -> Void)?

    private var listeners: [FileUploaderDelegate] = []

    /// Initialize from background.
    public convenience init?(backgroundSessionIdentifier id: String) {
        guard let session = Session(string: id), let user = Keychain.entries.first(where: { $0 == session }) else {
            return nil
        }
        let api = URLSessionAPI(accessToken: user.accessToken, actAsUserID: user.actAsUserID, baseURL: user.baseURL)
        let database = NSPersistentContainer.create(appGroup: session.appGroup?.rawValue, session: user)
        self.init(identifier: session.identifier, api: api, database: database, appGroup: session.appGroup)
    }

    /// Initialize from foreground.
    public convenience init(bundleID: String, appGroup: AppGroup?, environment: AppEnvironment = .shared) {
        guard let user = environment.currentSession else {
            self.init(identifier: "\(bundleID).fileuploads", api: URLSessionAPI(), database: .create(), appGroup: appGroup)
            return
        }
        let api = environment.api
        let database = environment.database
        let session = Session(bundleID: bundleID, appGroup: appGroup, userID: user.userID, baseURL: user.baseURL, actAsUserID: user.actAsUserID)
        let identifier = session.identifier
        self.init(identifier: identifier, api: api, database: database, appGroup: appGroup)
    }

    private init(identifier: String, api: API, database: NSPersistentContainer, appGroup: AppGroup?) {
        Logger.shared.log("Creating file uploader with identifier \(identifier)")
        self.api = api
        self.database = database
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.sharedContainerIdentifier = appGroup?.rawValue
        super.init()
        backgroundSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    public func upload(_ file: File, context: FileUploadContext, callback: @escaping (Error?) -> Void) {
        Logger.shared.log()
        let defaultError = NSError.instructureError(NSLocalizedString("Could not upload file", comment: ""))
        guard let url = file.localFileURL else {
            callback(defaultError)
            return
        }
        let objectID = file.objectID
        getTarget(context: context, name: url.lastPathComponent) { [weak self] target, error in
            guard let self = self else { return }
            if let error = error {
                callback(error)
                return
            }
            var task: URLSessionTask?
            var error: Error?
            let context = self.taskContext
            context.performAndWait {
                guard let target = target, let file = context.object(with: objectID) as? File else {
                    callback(defaultError)
                    return
                }
                do {
                    let request = PostFileUploadRequest(fileURL: url, target: target)
                    task = try self.backgroundAPI.uploadTask(request, fromFile: url)
                    file.taskID = task?.taskIdentifier
                    file.id = nil
                    try context.save()
                } catch let e {
                    error = e
                }
            }
            if error == nil {
                task?.resume()
            }
            callback(error)
        }
    }

    public func cancel(_ file: File) {
        guard let taskID = file.taskID else {
            return
        }
        backgroundSession.getAllTasks { tasks in
            tasks.first { $0.taskIdentifier == taskID }?.cancel()
        }
    }

    public func cancel(submission: NewSubmission, completionHandler: @escaping (Error?) -> Void) {
        let objectID = submission.objectID
        let context = taskContext
        context.performAndWait {
            guard let newSubmission = context.object(with: objectID) as? NewSubmission else {
                completionHandler(nil)
                return
            }
            let files = newSubmission.files ?? []
            for file in files {
                cancel(file)
            }
            context.delete(newSubmission)
            do {
                try context.save()
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }

    public func addListener(_ listener: FileUploaderDelegate) {
        listeners.append(listener)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Logger.shared.log()
        let context = taskContext
        context.performAndWait {
            guard let file: File = context.first(where: #keyPath(File.taskIDRaw), equals: NSNumber(value: task.taskIdentifier)) else {
                return
            }
            file.bytesSent = Int(totalBytesSent)
            file.size = Int(totalBytesExpectedToSend)
            do {
                try context.save()
            } catch {
                Logger.shared.error(error)
            }
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Logger.shared.log()
        let context = taskContext
        context.performAndWait {
            guard let file: File = context.first(where: #keyPath(File.taskIDRaw), equals: NSNumber(value: dataTask.taskIdentifier)) else {
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(APIFile.self, from: data)
                try file.update(fromApiModel: response, in: context)
            } catch {
                file.uploadError = error.localizedDescription
                Logger.shared.error(error)
            }
            do {
                try context.save()
            } catch {
                Logger.shared.error(error)
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Logger.shared.log()
        if let error = error {
            Logger.shared.error(error)
        }
        let context = taskContext
        context.performAndWait {
            guard let file: File = context.first(where: #keyPath(File.taskIDRaw), equals: NSNumber(value: task.taskIdentifier)) else {
                return
            }
            file.uploadError = error?.localizedDescription ?? file.uploadError
            file.taskID = nil
            do {
                try context.save()
            } catch {
                Logger.shared.error(error)
            }

            if let newSubmission = file.newSubmission {
                self.submit(newSubmission)
                context.refresh(newSubmission, mergeChanges: false)
            }
        }
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Logger.shared.log()
        self.completionHandler?()
        session.finishTasksAndInvalidate()
    }

    private func getTarget(context: FileUploadContext, name: String, callback: @escaping (FileUploadTarget?, Error?) -> Void) {
        Logger.shared.log()
        let body = PostFileUploadTargetRequest.Body(name: name, on_duplicate: .rename, parent_folder_id: nil)
        let request = PostFileUploadTargetRequest(context: context, body: body)
        api.makeRequest(request) { target, _, error in
            callback(target, error)
        }
    }
}

// MARK: - Submissions
extension FileUploader {
    private func submit(_ newSubmission: NewSubmission) {
        let files = newSubmission.files ?? []
        let ready = files.allSatisfy { $0.isUploaded } == true
        guard ready else { return }
        guard let assignment = newSubmission.assignment else { return }

        let fileIDs = newSubmission.files?.compactMap { $0.id } ?? []
        let courseID = assignment.courseID
        let assignmentID = assignment.id
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: nil,
            submission_type: .online_upload,
            body: nil,
            url: nil,
            file_ids: fileIDs,
            media_comment_id: nil,
            media_comment_type: nil
        )
        let request = CreateSubmissionRequest(
            context: ContextModel(.course, id: courseID),
            assignmentID: assignmentID,
            body: .init(submission: submission)
        )

        let objectID = newSubmission.objectID
        taskContext.refresh(assignment, mergeChanges: false)
        Logger.shared.log("Submitting \(fileIDs.count) files")
        self.api.makeRequest(request) { response, urlResponse, error in
            let context = self.submissionContext
            context.performAndWait {
                guard let newSubmission = context.object(with: objectID) as? NewSubmission else { return }
                guard let assignment = newSubmission.assignment else { return }
                let success = (urlResponse as? HTTPURLResponse)?.statusCode == 201
                if success {
                    Logger.shared.log("Created file submission!")
                    context.delete(newSubmission)
                    self.sendCompletedNotification(courseID: assignment.courseID, assignmentID: assignment.id)
                } else {
                    Logger.shared.log("Failed to create file submission.")
                    if let file = newSubmission.files?.first {
                        let message = error?.localizedDescription ?? NSLocalizedString("Submission failed.", comment: "")
                        file.uploadError = message
                        context.refresh(file, mergeChanges: false)
                    }
                    self.sendCompletedNotification(courseID: assignment.courseID, assignmentID: assignment.id)
                }
                do {
                    context.refresh(assignment, mergeChanges: false)
                    if let response = response {
                        try Submission.save(response, in: context)
                    }
                    try context.save()
                } catch {
                    Logger.shared.error(error)
                }
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

}

private func == (lhs: KeychainEntry, rhs: FileUploader.Session) -> Bool {
    return lhs.userID == rhs.userID &&
        lhs.baseURL == rhs.baseURL &&
        lhs.actAsUserID == rhs.actAsUserID
}
