
//
//  Session.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/22/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import SoLazy
import Result
import ReactiveCocoa
import Marshal
import WebKit // fixes random "library not loaded" errors.
import AVFoundation // fixes random "library not loaded" errors.

private let LocalStoreAppGroupName = "group.com.instructure.SoPersistent.LocalStore"

public class Session: NSObject {
    public enum LocalStoreDirectory: String {
        case Default, AppGroup
    }

    public let user: SessionUser
    public let baseURL: NSURL
    public let masqueradeAsUserID: String?
    public var URLSession: NSURLSession
    public var token: String?
    public let localStoreDirectory: LocalStoreDirectory

    public typealias ProgressBlock = (bytesSent: Int64, totalBytes: Int64)->()
    public var progressUpdateByTask: [NSURLSessionTask: ProgressBlock] = [:]

    public typealias TaskCompletionHandler = (NSURLSessionTask, NSError?)->()
    public var completionHandlerByTask: [NSURLSessionTask: TaskCompletionHandler] = [:]

    public typealias BackgroundCompletionHandler = NSError?->Void
    public var completionHandlerByBackgroundIdentifier: [String: BackgroundCompletionHandler] = [:]

    public var responseDataByTask: [NSURLSessionTask: NSMutableData] = [:]

    public static var unauthenticated: Session {
        return Session(baseURL: NSURL(), user: SessionUser(id: "", name: ""), token: nil)
    }

    public convenience init(baseURL: NSURL, user: SessionUser, token: String?, masqueradeAsUserID: String? = nil) {
        self.init(baseURL: baseURL, user: user, token: token, localStoreDirectory: .Default, masqueradeAsUserID: masqueradeAsUserID)
    }

    public init(baseURL: NSURL, user: SessionUser, token: String?, localStoreDirectory: LocalStoreDirectory, masqueradeAsUserID: String? = nil) {
        self.user = user
        self.masqueradeAsUserID = masqueradeAsUserID
        self.baseURL = baseURL
        self.token = token
        self.localStoreDirectory = localStoreDirectory

        
        URLSession = NSURLSession.sharedSession()
        
        super.init()

        // set up the authorized session with default headers
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = defaultHTTPHeaders
        let opQ = NSOperationQueue()
        opQ.name = "com.instructure.TooLegit.NSURLSessionDelegate"
        self.URLSession = NSURLSession(configuration: config, delegate: self, delegateQueue:opQ)
    }
    
    public var sessionID: String {
        let masq = masqueradeAsUserID.map { "-\($0)" } ?? ""
        let host = baseURL.host ?? "unknown-host"
        return "\(host)-\(user.id)\(masq)"
    }
    
    public var localStoreDirectoryURL: NSURL {
        let fileURL: NSURL

        switch localStoreDirectory {
        case .Default:
            guard let lib = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first else { ❨╯°□°❩╯⌢"GASP! There were no user library search paths" }
            fileURL = NSURL(fileURLWithPath: lib)
        case .AppGroup:
            guard let appGroup = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(LocalStoreAppGroupName) else {
                ❨╯°□°❩╯⌢"GASP! There is not an app group"
            }
            fileURL = appGroup
        }

        let url = fileURL.URLByAppendingPathComponent(sessionID)
        let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        return url
    }

    public var logDirectoryURL: NSURL {
        let fileURL: NSURL

        switch localStoreDirectory {
        case .Default:
            guard let lib = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else { ❨╯°□°❩╯⌢"GASP! There were no user library search paths" }
            fileURL = NSURL(fileURLWithPath: lib)
        case .AppGroup:
            guard let appGroup = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(LocalStoreAppGroupName) else {
                ❨╯°□°❩╯⌢"GASP! There is not an app group"
            }
            fileURL = appGroup
        }

        let url = fileURL.URLByAppendingPathComponent("\(sessionID)_logs")
        let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
}


extension Session {
    public static func fromJSON(data: [String: AnyObject]) -> Session? {
        let token = data["accessToken"] as? String
        let baseURL = (data["baseURL"] as? String).flatMap { NSURL(string: $0) }
        let user = (data["currentUser"] as? [String: AnyObject]).flatMap { SessionUser.fromJSON($0) }
        let masqueradeUserID = data["actAsUserID"] as? String
        let localStoreDirectory = (data["localStoreDirectory"] as? String).flatMap(LocalStoreDirectory.init) ?? .Default
        
        if let token = token, baseURL = baseURL, user = user {
            return Session(baseURL: baseURL, user: user, token: token, localStoreDirectory: localStoreDirectory, masqueradeAsUserID: masqueradeUserID)
        }
        return nil
    }
    
    public func dictionaryValue() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["accessToken"] = self.token
        dictionary["baseURL"] = self.baseURL.absoluteString
        dictionary["currentUser"] = self.user.JSONDictionary()
        dictionary["localStoreDirectory"] = self.localStoreDirectory.rawValue
        if let actAsUserID = self.masqueradeAsUserID {
            dictionary["actAsUserID"] = actAsUserID
        }
        return dictionary
    }

    public func compare(session: Session) -> Bool {
        // Same if Token is equal or userID & baseURL are equal
        return (self.token == session.token) || (session.user.id == self.user.id && session.baseURL.absoluteString == self.baseURL.absoluteString)
    }

    public func copyToBackgroundSessionWithIdentifier(identifier: String, sharedContainerIdentifier: String?) -> Session {
        guard let session = Session.fromJSON(self.dictionaryValue()) else {
            fatalError("session couldn't parse itself")
        }

        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        config.HTTPAdditionalHeaders = URLSession.configuration.HTTPAdditionalHeaders
        config.sharedContainerIdentifier = sharedContainerIdentifier
        let backgroundSession = NSURLSession(configuration: config, delegate: session, delegateQueue: nil)
        session.URLSession = backgroundSession
        return session
    }
}

extension Session: NSURLSessionTaskDelegate {
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        progressUpdateByTask[task]?(bytesSent: totalBytesSent, totalBytes: totalBytesExpectedToSend)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        progressUpdateByTask[task] = nil
        completionHandlerByTask[task]?(task, error)
        completionHandlerByTask[task] = nil
        responseDataByTask[task] = nil

        if let identifier = session.configuration.identifier {
            completionHandlerByBackgroundIdentifier[identifier]?(error)
            completionHandlerByBackgroundIdentifier[identifier] = nil
        }
    }
}

extension Session: NSURLSessionDataDelegate {
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        let responseData = responseDataByTask[dataTask] ?? NSMutableData()
        responseData.appendData(data)
        responseDataByTask[dataTask] = responseData
    }
}
