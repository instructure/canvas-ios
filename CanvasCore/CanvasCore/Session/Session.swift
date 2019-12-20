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

    public private(set) var env: AppEnvironment
    public var api: API {
        return env.api
    }
    @objc public private(set) var baseURL: URL
    @objc public private(set) var user: SessionUser
    public let URLSession: Foundation.URLSession
    public let localStoreDirectory: LocalStoreDirectory

    fileprivate static var _current: Session?
    @objc public static var current: Session? {
        if let current = _current, let loginSession = AppEnvironment.shared.currentSession {
            current.env = AppEnvironment.shared
            current.baseURL = loginSession.baseURL
            current.user = SessionUser(loginSession: loginSession)
            return current
        }
        _current = Session(environment: .shared)
        return _current
    }

    private init?(environment: AppEnvironment = .shared) {
        guard let session = environment.currentSession, let api = environment.api as? URLSessionAPI else { return nil }
        self.env = environment
        self.baseURL = session.baseURL
        self.user = SessionUser(loginSession: session)
        self.URLSession = api.urlSession
        self.localStoreDirectory = .AppGroup
    }
    
    @objc open var sessionID: String {
        let host = baseURL.host ?? "unknown-host"
        let userID = user.id
        var components = [host, userID]
        if let masq = env.currentSession?.originalUserID {
            components.append(masq)
        }
        return components.joined(separator: "-")
    }
    
    @objc open var isSiteAdmin: Bool {
        return env.currentSession?.baseURL.host?.lowercased().contains("siteadmin") == true
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

extension SessionUser {
    convenience init(loginSession: LoginSession) {
        self.init(
            id: loginSession.userID,
            name: loginSession.userName,
            loginID: nil,
            sortableName: loginSession.userName,
            email: loginSession.userEmail,
            avatarURL: loginSession.userAvatarURL
        )
    }
}

#if DEBUG
extension Session {
    static func reset() {
        current?.refreshScope.invalidateAllCaches()
        _current = nil
    }
}
#endif
