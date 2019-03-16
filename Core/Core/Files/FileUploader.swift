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

public protocol FileUploadDelegate {
    func fileUploader(_ fileUploader: FileUploader, url: URL, didCompleteWithError error: Error?)
}

public class FileUploader: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    struct File: Decodable {
        let id: ID
    }

    public let identifier: String
    public var completionHandler: (() -> Void)?
    var backgroundSession: URLSession!
    lazy var backgroundAPI: API = URLSessionAPI(urlSession: backgroundSession)
    var listeners: [FileUploadDelegate] = []
    public let database: NSPersistentContainer

    public init(appGroup: AppGroup, identifier: String = "file-uploads", environment: AppEnvironment = .shared) {
        self.identifier = identifier
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.sharedContainerIdentifier = appGroup.rawValue

        // File uploads are stored in the `globalDatabase`
        // because they continue across sessions.
        self.database = environment.globalDatabase

        super.init()
        backgroundSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    public func upload(_ fileURL: URL, for uploadContext: FileUploadContext, environment: AppEnvironment = .shared) {
        Logger.shared.log(#function)
        database.perform { context in
            let fileUpload: FileUpload = context.first(where: #keyPath(FileUpload.url), equals: fileURL as CVarArg) ?? context.insert()
            fileUpload.reset()
            fileUpload.url = fileURL
            fileUpload.context = uploadContext
            fileUpload.user = environment.currentSession

            do {
                try context.save()
                self.getTarget(fileUpload, api: environment.api)
            } catch {
                self.notify(url: fileURL, error: error)
            }
        }
    }

    public func subscribe<U: UseCase>(_ useCase: U, callback: @escaping () -> Void) -> Store<U> {
        let environment = AppEnvironment()
        environment.database = database
        return environment.subscribe(useCase, callback)
    }

    public func addListener(_ delegate: FileUploadDelegate) {
        listeners.append(delegate)
    }

    private func getTarget(_ fileUpload: FileUpload, api: API) {
        guard let context = fileUpload.context else { return }
        let body = PostFileUploadTargetRequest.Body(name: fileUpload.url.lastPathComponent, on_duplicate: .rename, parent_folder_id: nil)
        let request = PostFileUploadTargetRequest(context: context, body: body)
        let url = fileUpload.url
        api.makeRequest(request) { target, _, error in
            if let error = error {
                self.database.perform { context in
                    if let fileUpload = self.fileUpload(for: url, in: context) {
                        fileUpload.error = error.localizedDescription
                        _ = try? context.save()
                    }
                    self.notify(url: url, error: error)
                }
                return
            }
            guard let target = target else {
                return
            }
            self.post(file: url, to: target)
        }
    }

    private func post(file: URL, to target: FileUploadTarget) {
        database.perform { context in
            guard let fileUpload = self.fileUpload(for: file, in: context) else {
                return
            }
            do {
                let request = PostFileUploadRequest(fileURL: file, target: target)
                let task = try self.backgroundAPI.uploadTask(request, fromFile: file)
                fileUpload.taskID = task.taskIdentifier
                fileUpload.sessionID = self.identifier
                try context.save()
                task.resume()
            } catch {
                self.notify(url: file, error: error)
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Logger.shared.log(#function)
        database.perform { context in
            guard let fileUpload = self.fileUpload(for: task, in: context) else {
                return
            }
            do {
                fileUpload.bytesSent = Int(totalBytesSent)
                fileUpload.size = Int(totalBytesExpectedToSend)
                try context.save()
            } catch {
                self.notify(url: fileUpload.url, error: error)
                task.cancel()
            }
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Logger.shared.log(#function)
        database.perform { context in
            guard let fileUpload = self.fileUpload(for: dataTask, in: context) else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let file = try decoder.decode(File.self, from: data)
                fileUpload.fileID = file.id.value
                try context.save()
                Logger.shared.log("Uploaded file with id \(file.id)")
            } catch {
                fileUpload.error = error.localizedDescription
                _ = try? context.save()
                self.notify(url: fileUpload.url, error: error)
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Logger.shared.log(#function)
        database.perform { context in
            guard let fileUpload = self.fileUpload(for: task, in: context) else {
                return
            }
            do {
                let error = fileUpload.error ?? error?.localizedDescription
                fileUpload.error = error
                fileUpload.completed = error == nil
                try context.save()
                self.notify(url: fileUpload.url, error: nil)
            } catch {
                self.notify(url: fileUpload.url, error: error)
            }
        }
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Logger.shared.log(#function)
        session.finishTasksAndInvalidate()
    }

    private func fileUpload(for url: URL, in context: PersistenceClient) -> FileUpload? {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(FileUpload.url), url as CVarArg)
        return context.fetch(predicate).first
    }

    private func fileUpload(for task: URLSessionTask, in context: PersistenceClient) -> FileUpload? {
        let sessionID = NSPredicate(format: "%K == %@", #keyPath(FileUpload.sessionID), identifier)
        let taskID = NSPredicate(format: "%K == %d", #keyPath(FileUpload.taskIDRaw), task.taskIdentifier)
        let notCompleted = NSPredicate(format: "%K == %@", #keyPath(FileUpload.completed), NSNumber(value: false))
        let notFailed = NSPredicate(format: "%K == nil", #keyPath(FileUpload.error))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sessionID, taskID, notCompleted, notFailed])
        return context.fetch(predicate).first
    }

    private func notify(url: URL, error: Error?) {
        let listeners = self.listeners
        for listener in listeners {
            listener.fileUploader(self, url: url, didCompleteWithError: error)
        }
    }
}
