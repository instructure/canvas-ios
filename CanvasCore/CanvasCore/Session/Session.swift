//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import ReactiveSwift
import Marshal
import WebKit // fixes random "library not loaded" errors.
import AVFoundation // fixes random "library not loaded" errors.
import Core

let LocalStoreAppGroupName = "group.com.instructure.Contexts"

open class Session: NSObject {
    public enum LocalStoreDirectory: String {
        case Default, AppGroup
    }

    @objc public let user: SessionUser
    @objc public let baseURL: URL
    @objc public let masqueradeAsUserID: String?
    @objc open var URLSession: Foundation.URLSession {
        return URLSessionAPI.defaultURLSession
    }
    open lazy var api: API = URLSessionAPI(accessToken: token, refreshToken: refreshToken, actAsUserID: masqueradeAsUserID, clientID: clientID, clientSecret: clientSecret, baseURL: baseURL, urlSession: URLSession)
    @objc open var token: String?
    @objc open var refreshToken: String?
    @objc open var clientID: String?
    @objc open var clientSecret: String?
    public let localStoreDirectory: LocalStoreDirectory

    @objc public static var unauthenticated: Session {
        return Session(baseURL: URL(string: "https://canvas.instructure.com/")!, user: SessionUser(id: "", name: ""), token: nil, refreshToken: nil, clientID: nil, clientSecret: nil)
    }

    @objc public convenience init(baseURL: URL, user: SessionUser, token: String?, refreshToken: String?, clientID: String?, clientSecret: String?, masqueradeAsUserID: String? = nil) {
        self.init(baseURL: baseURL, user: user, token: token, refreshToken: refreshToken, clientID: clientID, clientSecret: clientSecret, localStoreDirectory: .AppGroup, masqueradeAsUserID: masqueradeAsUserID)
    }

    public init(baseURL: URL, user: SessionUser, token: String?, refreshToken: String?, clientID: String?, clientSecret: String?, localStoreDirectory: LocalStoreDirectory, masqueradeAsUserID: String? = nil) {
        self.user = user
        self.masqueradeAsUserID = masqueradeAsUserID
        self.baseURL = baseURL
        self.token = token
        self.refreshToken = refreshToken
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.localStoreDirectory = localStoreDirectory
    }
    
    @objc open var sessionID: String {
        let host = baseURL.host ?? "unknown-host"
        let userID = user.id
        var components = [host, userID]
        if let masq = masqueradeAsUserID {
            components.append(masq)
        }
        return components.joined(separator: "-")
    }
    
    @objc open var isSiteAdmin: Bool {
        guard let host = baseURL.host else { return false }

        return host.lowercased().contains("siteadmin")
    }
    
    @objc open var localStoreDirectoryURL: URL {
        let fileURL: URL

        switch localStoreDirectory {
        case .Default:
            guard let lib = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { fatalError("GASP! There were no user library search paths") }
            fileURL = URL(fileURLWithPath: lib)
        case .AppGroup:
            guard let appGroup = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: LocalStoreAppGroupName) else {
                fatalError("GASP! There is not an app group")
            }
            fileURL = appGroup
        }

        let url = fileURL.appendingPathComponent(sessionID)
        let _ = try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }

    @objc open var logDirectoryURL: URL {
        let fileURL: URL

        switch localStoreDirectory {
        case .Default:
            guard let lib = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { fatalError("GASP! There were no user library search paths") }
            fileURL = URL(fileURLWithPath: lib)
        case .AppGroup:
            guard let appGroup = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: LocalStoreAppGroupName) else {
                fatalError("GASP! There is not an app group")
            }
            fileURL = appGroup
        }

        let url = fileURL.appendingPathComponent("\(sessionID)_logs")
        let _ = try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
}


extension Session {
    @objc public func compare(_ session: Session) -> Bool {
        // Same if Token is equal or userID & baseURL are equal
        return (self.token == session.token) || (session.user.id == self.user.id && session.baseURL.absoluteString == self.baseURL.absoluteString)
    }
}
