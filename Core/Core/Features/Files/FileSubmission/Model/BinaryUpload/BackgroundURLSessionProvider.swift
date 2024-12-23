//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

/**
 This class manages the lifecycle of a background `URLSession`. It creates it, keeps it alive, waits until the session
 finishes then tears it down. If a session is required while the previous is already destroyed then this class re-creates it.
 */
public class BackgroundURLSessionProvider: NSObject {
    public var session: URLSession {
        if let activeSession = activeSession {
            return activeSession
        }
        let session = createSession()
        activeSession = session
        return session
    }

    private var activeSession: URLSession?
    private let sessionID: String
    private let sharedContainerID: String
    private let sessionConfigurationProtocolClasses: [AnyClass]?
    private let uploadProgressObserversCache: FileUploadProgressObserversCache

    /**
     - parameters:
        - sessionID: The background session identifier. Must be unique for each process (app / share extension).
        - sharedContainerID: The container identifier shared between the app and its extensions. Background URLSession read/write this directory.
        - sessionConfigurationProtocolClasses: Protocol handler configurations. Not needed by default, used for unit test targets only.
     */
    public init(
        sessionID: String,
        sharedContainerID: String,
        sessionConfigurationProtocolClasses: [AnyClass]? = nil,
        uploadProgressObserversCache: FileUploadProgressObserversCache
    ) {
        self.sessionID = sessionID
        self.sharedContainerID = sharedContainerID
        self.sessionConfigurationProtocolClasses = sessionConfigurationProtocolClasses
        self.uploadProgressObserversCache = uploadProgressObserversCache
    }

    private func createSession() -> URLSession {
        let configuration: URLSessionConfiguration

        if let sessionConfigurationProtocolClasses {
            configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = sessionConfigurationProtocolClasses
        } else {
            configuration = URLSessionConfiguration.background(withIdentifier: sessionID)
        }
        configuration.sharedContainerIdentifier = sharedContainerID
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
}

extension BackgroundURLSessionProvider: URLSessionDelegate {
    /**
     The session became invalid and it's no longer safe to use. We clear up the cached instance so next time a new session will be created.
     */
    public func urlSession(_: URLSession, didBecomeInvalidWithError _: Error?) {
        activeSession = nil
    }

    /**
     If there are no more events to handle in this background session then we invalidate it
     and call the completion handler received via `UIApplicationDelegate:handleEventsForBackgroundURLSession`.
     */
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.finishTasksAndInvalidate()
    }
}

extension BackgroundURLSessionProvider: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        uploadProgressObserversCache.urlSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        uploadProgressObserversCache.urlSession(session, task: task, didCompleteWithError: error)
    }
}

extension BackgroundURLSessionProvider: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        uploadProgressObserversCache.urlSession(session, dataTask: dataTask, didReceive: data)
    }
}
