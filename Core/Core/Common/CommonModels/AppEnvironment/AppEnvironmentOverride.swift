//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import CoreData
import UIKit

/// The main purpose of this entity is to create a new `AppEnvironment` that points to a different host
/// so we can inject this instead of using the `.shared` instance when we need to connect to a different host when a course is on a different URL.
public final class AppEnvironmentOverride: AppEnvironment {

    let base: AppEnvironment
    let baseURL: URL
    private(set) var _contextShardID: String?

    fileprivate init(base: AppEnvironment, baseURL: URL, contextShardID: String?) {
        self.base = base
        self.baseURL = baseURL
        self._contextShardID = contextShardID
        super.init()
    }

    private lazy var apiOverride: API = {
        API(currentSession, baseURL: baseURL)
    }()

    public override var root: AppEnvironment { base }

    public override var sessionShardID: String? { base.sessionShardID }
    public override var contextShardID: String? { _contextShardID ?? sessionShardID }

    public override var app: AppEnvironment.App? {
        get { base.app }
        set {}
    }

    public override var router: Router {
        get { base.router }
        set {}
    }

    public override var api: API {
        get { apiOverride }
        set {}
    }

    public override var k5: K5State {
        base.k5
    }

    public override var database: NSPersistentContainer {
        get { base.database }
        set {}
    }

    public override var globalDatabase: NSPersistentContainer {
        get { base.globalDatabase }
        set {}
    }

    public override var userDefaults: SessionDefaults? {
        get { base.userDefaults }
        set {}
    }

    public override weak var loginDelegate: LoginDelegate? {
        get { base.loginDelegate }
        set { base.loginDelegate = newValue }
    }

    public override weak var window: UIWindow? {
        get { base.window }
        set { base.window = newValue }
    }

    public override var currentSession: LoginSession? {
        get {
            guard let cSession = base.currentSession else { return nil }

            let userID: String
            if let userShardID = cSession.userID.shardID, userShardID == contextShardID {
                // If user share the same shardID of the course/group, it means it belong to the
                // same account hosting the course/group. Course/Group content APIs would always respond
                // with local-form user ID
                userID = cSession.userID.localID
            } else {
                // If user doesn't share the same shardID of the course/group.
                // Course/Group content APIs requires the global-form user ID to succeed.
                // Examples: Course/group hosted in a trusted account, or in a cross-shard account
                // which current user doesn't belong to.
                userID = cSession.userID.asGlobalID(of: cSession.accessToken?.shardID)
            }

            return LoginSession(
                accessToken: cSession.accessToken,
                baseURL: baseURL, // This is important to authenticate requests
                expiresAt: cSession.expiresAt,
                lastUsedAt: cSession.lastUsedAt,
                locale: cSession.locale,
                masquerader: cSession.masquerader,
                refreshToken: cSession.refreshToken,
                userAvatarURL: cSession.userAvatarURL,
                userID: userID,
                userName: cSession.userName,
                userEmail: cSession.userEmail,
                clientID: cSession.clientID,
                clientSecret: cSession.clientSecret,
                canvasRegion: cSession.canvasRegion,
                isFakeStudent: cSession.isFakeStudent
            )
        }
        set {}
    }

    public override func transformContentIDsToLocalForm(params: [String: String], url: URLComponents) -> ([String: String], URLComponents) {
        var newParams: [String: String] = [:]
        var newUrl = url

        params.forEach { (key, value) in
            // Localize IDs except for userID params
            if key.lowercased() == "userID".lowercased() {
                newParams[key] = value
            } else if key.lowercased().hasSuffix("id") {
                newParams[key] = value.localID
                newUrl.path = newUrl.path.replacingOccurrences(of: value, with: value.localID)
            } else {
                newParams[key] = value
            }
        }

        // Fix query items
        newUrl.queryItems = url.queryItems?.map({ item in
            if ["courseID", "assignmentID", "assignment_id"].contains(item.name) {
                var newItem = item
                newItem.value = item.value?.localID
                return newItem
            }

            return item
        })

        return (newParams, newUrl)
    }
}

extension AppEnvironment {

    /// This method returns an `AppEnvironmentOverride` using the given `url`s host if it
    /// doesn't match the one on `AppEnvironment.shared`.
    static func resolved(for url: URLComponents, contextShardID: String?) -> AppEnvironment {
        if let host = url.host, host != shared.api.baseURL.host(),
           let baseURL = url.with(scheme: shared.api.baseURL.scheme).url?.apiBaseURL {
            return AppEnvironmentOverride(
                base: shared,
                baseURL: baseURL,
                contextShardID: contextShardID
            )
        }

        return .shared
    }

    /// This method returns an `AppEnvironmentOverride` using the given `baseURL`s host if it
    /// doesn't match the one on `AppEnvironment.shared`.
    public static func resolved(for baseURL: URL?, contextShardID: String?) -> AppEnvironment {
        guard
            let baseURL,
            let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else { return .shared }
        return resolved(for: components, contextShardID: contextShardID)
    }
}

// MARK: - Utils

extension String {

    public func asRoute(in env: AppEnvironment) -> String {
        // Skip for full valid URLs
        if isFullURLString { return self }

        // Skip when baseURL equals to the shared one.
        if env.api.baseURL == AppEnvironment.shared.api.baseURL { return self }

        return env.api.baseURL.appending(path: self).absoluteString
    }

    private var isFullURLString: Bool {
        guard let url = URL(string: self) else { return false }
        return url.host() != nil
    }
}

private extension URLComponents {
    func with(scheme: String?) -> Self {
        var copy = self
        copy.scheme = scheme
        return copy
    }
}
