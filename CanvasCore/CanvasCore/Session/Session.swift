//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation

import Result
import ReactiveSwift
import Marshal
import WebKit // fixes random "library not loaded" errors.
import AVFoundation // fixes random "library not loaded" errors.

let LocalStoreAppGroupName = "group.com.instructure.Contexts"

open class Session: NSObject {
    public enum LocalStoreDirectory: String {
        case Default, AppGroup
    }

    open let user: SessionUser
    open let baseURL: URL
    open let masqueradeAsUserID: String?
    open var URLSession: Foundation.URLSession
    open var token: String?
    open let localStoreDirectory: LocalStoreDirectory

    public typealias ProgressBlock = (_ bytesSent: Int64, _ totalBytes: Int64)->()
    open var progressUpdateByTask: [URLSessionTask: ProgressBlock] = [:]

    public typealias TaskCompletionHandler = (URLSessionTask, NSError?)->()
    open var completionHandlerByTask: [URLSessionTask: TaskCompletionHandler] = [:]

    public typealias BackgroundCompletionHandler = (NSError?)->Void
    open var completionHandlerByBackgroundIdentifier: [String: BackgroundCompletionHandler] = [:]

    open var responseDataByTask: [URLSessionTask: Data] = [:]

    open static var unauthenticated: Session {
        return Session(baseURL: URL(string: "https://canvas.instructure.com/")!, user: SessionUser(id: "", name: ""), token: nil)
    }

    public convenience init(baseURL: URL, user: SessionUser, token: String?, masqueradeAsUserID: String? = nil) {
        self.init(baseURL: baseURL, user: user, token: token, localStoreDirectory: .AppGroup, masqueradeAsUserID: masqueradeAsUserID)
    }

    public init(baseURL: URL, user: SessionUser, token: String?, localStoreDirectory: LocalStoreDirectory, masqueradeAsUserID: String? = nil) {
        self.user = user
        self.masqueradeAsUserID = masqueradeAsUserID
        self.baseURL = baseURL
        self.token = token
        self.localStoreDirectory = localStoreDirectory

        
        URLSession = Foundation.URLSession.shared
        
        super.init()

        // set up the authorized session with default headers
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = defaultHTTPHeaders
        let opQ = OperationQueue()
        opQ.name = "com.instructure.TooLegit.URLSessionDelegate"
        self.URLSession = Foundation.URLSession(configuration: config, delegate: self, delegateQueue:opQ)
    }
    
    open var sessionID: String {
        let host = baseURL.host ?? "unknown-host"
        let userID = user.id
        var components = [host, userID]
        if let masq = masqueradeAsUserID {
            components.append(masq)
        }
        return components.joined(separator: "-")
    }
    
    open var localStoreDirectoryURL: URL {
        let fileURL: URL

        switch localStoreDirectory {
        case .Default:
            guard let lib = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else { ❨╯°□°❩╯⌢"GASP! There were no user library search paths" }
            fileURL = URL(fileURLWithPath: lib)
        case .AppGroup:
            guard let appGroup = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: LocalStoreAppGroupName) else {
                ❨╯°□°❩╯⌢"GASP! There is not an app group"
            }
            fileURL = appGroup
        }

        let url = fileURL.appendingPathComponent(sessionID)
        let _ = try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }

    open var logDirectoryURL: URL {
        let fileURL: URL

        switch localStoreDirectory {
        case .Default:
            guard let lib = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { ❨╯°□°❩╯⌢"GASP! There were no user library search paths" }
            fileURL = URL(fileURLWithPath: lib)
        case .AppGroup:
            guard let appGroup = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: LocalStoreAppGroupName) else {
                ❨╯°□°❩╯⌢"GASP! There is not an app group"
            }
            fileURL = appGroup
        }

        let url = fileURL.appendingPathComponent("\(sessionID)_logs")
        let _ = try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
}


extension Session {
    public static func fromJSON(_ data: [String: Any]) -> Session? {
        let token = data["accessToken"] as? String
        let baseURL = (data["baseURL"] as? String).flatMap { URL(string: $0) }
        let user = (data["currentUser"] as? [String: AnyObject]).flatMap { SessionUser.fromJSON($0) }
        let masqueradeUserID = data["actAsUserID"] as? String
        let localStoreDirectory = (data["localStoreDirectory"] as? String).flatMap(LocalStoreDirectory.init) ?? .AppGroup
        
        if let token = token, let baseURL = baseURL, let user = user {
            return Session(baseURL: baseURL, user: user, token: token, localStoreDirectory: localStoreDirectory, masqueradeAsUserID: masqueradeUserID)
        }
        return nil
    }
    
    public func dictionaryValue() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary["accessToken"] = self.token
        dictionary["baseURL"] = self.baseURL.absoluteString
        dictionary["currentUser"] = self.user.JSONDictionary()
        dictionary["localStoreDirectory"] = self.localStoreDirectory.rawValue
        if let actAsUserID = self.masqueradeAsUserID {
            dictionary["actAsUserID"] = actAsUserID
        }
        return dictionary
    }

    public func compare(_ session: Session) -> Bool {
        // Same if Token is equal or userID & baseURL are equal
        return (self.token == session.token) || (session.user.id == self.user.id && session.baseURL.absoluteString == self.baseURL.absoluteString)
    }

    public func copyToBackgroundSessionWithIdentifier(_ identifier: String, sharedContainerIdentifier: String?) -> Session {
        guard let session = Session.fromJSON(self.dictionaryValue()) else {
            fatalError("session couldn't parse itself")
        }

        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        config.httpAdditionalHeaders = URLSession.configuration.httpAdditionalHeaders
        config.sharedContainerIdentifier = sharedContainerIdentifier
        let backgroundSession = Foundation.URLSession(configuration: config, delegate: session, delegateQueue: nil)
        session.URLSession = backgroundSession
        return session
    }
}

extension Session: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        progressUpdateByTask[task]?(totalBytesSent, totalBytesExpectedToSend)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        progressUpdateByTask[task] = nil
        completionHandlerByTask[task]?(task, error as NSError?)
        completionHandlerByTask[task] = nil
        responseDataByTask[task] = nil

        if let identifier = session.configuration.identifier {
            completionHandlerByBackgroundIdentifier[identifier]?(error as NSError?)
            completionHandlerByBackgroundIdentifier[identifier] = nil
        }
    }
}

extension Session: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        var responseData = responseDataByTask[dataTask] ?? Data()
        responseData.append(data)
        responseDataByTask[dataTask] = responseData
    }
}
