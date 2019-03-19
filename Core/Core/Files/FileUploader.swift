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
        getTarget(context: context, name: url.lastPathComponent) { target, error in
            if let error = error {
                callback(error)
                return
            }
            var task: URLSessionTask?
            var error: Error?
            self.performAndWait { context in
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
                Logger.shared.log("Starting upload \(String(describing: task?.taskIdentifier))")
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

    public func addListener(_ listener: FileUploaderDelegate) {
        listeners.append(listener)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Logger.shared.log()
        performAndWait { context in
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
        performAndWait { context in
            guard let file: File = context.first(where: #keyPath(File.taskIDRaw), equals: NSNumber(value: dataTask.taskIdentifier)) else {
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(APIFile.self, from: data)
                Logger.shared.log("Created a file with id \(response.id)")
                try file.update(fromAPIModel: response)
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
        performAndWait { context in
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
            if let assignmentID = file.assignmentID, let courseID = file.courseID {
                self.submit(assignmentID: assignmentID, courseID: courseID)
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

    private func performAndWait(block: (NSManagedObjectContext) -> Void) {
        let context = database.newBackgroundContext()
        context.performAndWait {
            block(context)
        }
    }
}

// MARK: - Submissions
extension FileUploader {
    private func submit(assignmentID: String, courseID: String) {
        performAndWait { context in
            let files: [File] = context.all(where: #keyPath(File.assignmentID), equals: assignmentID)
            let ready = files.allSatisfy { $0.isUploaded } == true
            guard ready else { return }

            let fileIDs = files.compactMap { $0.id }
            Logger.shared.log("Submitting \(fileIDs.count) files")
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

            self.api.makeRequest(request) { response, _, error in
                self.handle(fileIDs: fileIDs, courseID: courseID, assignmentID: assignmentID, response: response, error: error)
            }
        }
    }

    private func handle(fileIDs: [String], courseID: String, assignmentID: String, response: APISubmission?, error: Error?) {
        self.performAndWait { context in
            let predicate = NSPredicate(format: "%K in %@", #keyPath(File.id), fileIDs)
            let files: [File] = context.fetch(predicate)
            let success = error == nil && response != nil
            if success {
                Logger.shared.log("Created file submission!")
                for file in files {
                    file.markSubmitted()
                }
                self.sendCompletedNotification(courseID: courseID, assignmentID: assignmentID)
            } else {
                Logger.shared.log("Failed to create file submission.")
                let message = error?.localizedDescription ?? NSLocalizedString("Submission failed.", comment: "")
                files.first?.uploadError = message
                self.sendCompletedNotification(courseID: courseID, assignmentID: assignmentID)
            }
            do {
                if let response = response {
                    try Submission.save(response, in: context)
                }
                try context.save()
            } catch {
                Logger.shared.error(error)
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
