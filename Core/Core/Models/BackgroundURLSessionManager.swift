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
import CoreData

public protocol BackgroundURLSessionDelegateEventHandler: class {
    /// Called each time a task finishes
    func urlSessionDidFinishEvent(forBackgroundURLSession session: URLSession)

    /// Called when the app was in the background when the session finished all events
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)
}

class BackgroundURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    weak var eventHandler: BackgroundURLSessionDelegateEventHandler?
    let queue: OperationQueue
    let database: Persistence

    init(eventHandler: BackgroundURLSessionDelegateEventHandler?, database: Persistence, queue: OperationQueue = OperationQueue()) {
        self.eventHandler = eventHandler
        self.database = database
        self.queue = queue
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Logger.shared.log(#function)
        guard let identifier = session.configuration.identifier else {
            return
        }
        let updateFile = UpdateFileUploadProgress(backgroundSessionID: identifier, task: task, bytesSent: totalBytesSent, expectedToSend: totalBytesExpectedToSend, database: database)
        queue.addOperations([updateFile], waitUntilFinished: true)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Logger.shared.log(#function)
        guard let identifier = session.configuration.identifier else {
            return
        }
        let updateFile = UpdateFileUploadData(backgroundSessionID: identifier, task: dataTask, data: data, database: database)
        queue.addOperations([updateFile], waitUntilFinished: true)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let errorMessage = error?.localizedDescription ?? "No error"
        Logger.shared.log("\(#function), \(errorMessage)")
        guard let identifier = session.configuration.identifier else {
            return
        }
        let updateFile = CompleteFileUpload(backgroundSessionID: identifier, task: task, error: error, database: database)
        let notify = BlockOperation { [weak self] in
            self?.eventHandler?.urlSessionDidFinishEvent(forBackgroundURLSession: session)
        }
        notify.addDependency(updateFile)
        queue.addOperations([updateFile, notify], waitUntilFinished: true)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Logger.shared.log(#function)
        eventHandler?.urlSessionDidFinishEvents(forBackgroundURLSession: session)
    }
}

open class BackgroundURLSessionManager {
    let appID: String
    let appGroup: String?
    public weak var eventsHandler: BackgroundURLSessionDelegateEventHandler?
    var session: KeychainEntry?
    var database: Persistence
    var mainIdentifier: String {
        return session.flatMap { "\(appID).background-session.user-\($0.userID)" } ?? "\(appID).background-session"
    }
    private var sessions: [String: URLSession] = [:]
    private var completionHandlers: [String: () -> Void] = [:]

    open var backgroundAPI: API {
        return URLSessionAPI(accessToken: session?.accessToken, actAsUserID: session?.actAsUserID, baseURL: session?.baseURL, urlSession: main)
    }

    public init(
        appID: String = Bundle.main.bundleIdentifier ?? Bundle.coreBundleID,
        appGroup: String? = Bundle.main.appGroupID(),
        session: KeychainEntry? = nil,
        database: Persistence
        ) {
        self.appID = appID
        self.appGroup = appGroup
        self.session = session
        self.database = database
    }

    public var main: URLSession {
        return sessions[mainIdentifier] ?? create(withIdentifier: mainIdentifier)
    }

    @discardableResult
    public func create(withIdentifier identifier: String) -> URLSession {
        Logger.shared.log("creating session with identifier \(identifier)")
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.sharedContainerIdentifier = appGroup
        let delegate = BackgroundURLSessionDelegate(eventHandler: eventsHandler, database: database)
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        add(session: session, withIdentifier: identifier)
        return session
    }

    public func complete(session: URLSession) {
        guard let identifier = session.configuration.identifier else {
            return
        }
        Logger.shared.log("completing session with identifier \(identifier)")
        DispatchQueue.main.async {
            self.completionHandlers[identifier]?()
            self.completionHandlers.removeValue(forKey: identifier)
            if let session = self.sessions[identifier] {
                session.finishTasksAndInvalidate()
                self.sessions.removeValue(forKey: identifier)
            }
        }
    }

    public func add(session: URLSession, withIdentifier identifier: String) {
        sessions[identifier] = session
    }

    public func add(completionHandler: @escaping () -> Void, forIdentifier identifier: String) {
        completionHandlers[identifier] = completionHandler
    }
}
