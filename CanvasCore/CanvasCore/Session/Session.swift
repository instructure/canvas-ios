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

let LocalStoreAppGroupName = "group.com.instructure.Contexts"

open class Session: NSObject {
    public enum LocalStoreDirectory: String {
        case Default, AppGroup
    }

    @objc public let user: SessionUser
    @objc public let baseURL: URL
    @objc public let masqueradeAsUserID: String?
    @objc open var URLSession: Foundation.URLSession
    @objc open var token: String?
    public let localStoreDirectory: LocalStoreDirectory

    @objc public static var unauthenticated: Session {
        return Session(baseURL: URL(string: "https://canvas.instructure.com/")!, user: SessionUser(id: "", name: ""), token: nil)
    }

    @objc public convenience init(baseURL: URL, user: SessionUser, token: String?, masqueradeAsUserID: String? = nil) {
        self.init(baseURL: baseURL, user: user, token: token, localStoreDirectory: .AppGroup, masqueradeAsUserID: masqueradeAsUserID)
    }

    public init(baseURL: URL, user: SessionUser, token: String?, localStoreDirectory: LocalStoreDirectory, masqueradeAsUserID: String? = nil) {
        self.user = user
        self.masqueradeAsUserID = masqueradeAsUserID
        self.baseURL = baseURL
        self.token = token
        self.localStoreDirectory = localStoreDirectory
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = defaultHTTPHeaders
        URLSession = Foundation.URLSession(configuration: config)
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
    @objc public static func fromJSON(_ data: [String: Any]) -> Session? {
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
    
    @objc public func dictionaryValue() -> [String: Any] {
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

    @objc public func compare(_ session: Session) -> Bool {
        // Same if Token is equal or userID & baseURL are equal
        return (self.token == session.token) || (session.user.id == self.user.id && session.baseURL.absoluteString == self.baseURL.absoluteString)
    }
}
