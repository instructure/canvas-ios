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
    private(set) var _courseShardID: String?

    fileprivate init(base: AppEnvironment, baseURL: URL, shardID: String?) {
        self.base = base
        self.baseURL = baseURL
        self._courseShardID = shardID
        super.init()
    }

    private lazy var apiOverride: API = {
        API(currentSession, baseURL: baseURL)
    }()

    public override var root: AppEnvironment { base }
    public override var courseShardID: String? { _courseShardID ?? sessionShardID }

    fileprivate func resetCourseShardIDOverride(_ shardID: String) {
        self._courseShardID = shardID
    }

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

            return LoginSession(
                accessToken: cSession.accessToken,
                baseURL: baseURL, // This is important to authenticate requests
                expiresAt: cSession.expiresAt,
                lastUsedAt: cSession.lastUsedAt,
                locale: cSession.locale,
                masquerader: cSession.masquerader,
                refreshToken: cSession.refreshToken,
                userAvatarURL: cSession.userAvatarURL,
                userID: cSession.userID.localID,
                userName: cSession.userName,
                userEmail: cSession.userEmail,
                clientID: cSession.clientID,
                clientSecret: cSession.clientSecret,
                isFakeStudent: cSession.isFakeStudent
            )
        }
        set {}
    }
}

extension AppEnvironment {
    private static let courseShardIdOverrideUserInfoKey: String = "courseShardIdOverride"

    var courseShardIDUserInfo: [String: Any]? {
        guard let shardID = (self as? AppEnvironmentOverride)?._courseShardID
        else { return nil }
        return [ Self.courseShardIdOverrideUserInfoKey: shardID ]
    }

    /// This method returns an `AppEnvironmentOverride` using the given `url`s host if it
    /// doesn't match the one on `AppEnvironment.shared`.
    static func resolved(for url: URLComponents) -> AppEnvironment {
        if let host = url.host, host != shared.api.baseURL.host(),
           let baseURL = url.with(scheme: shared.api.baseURL.scheme).url?.apiBaseURL {

            let params = Route("/courses/:courseID/:tabName").match(url)
            let shardID = params?["courseID"]?.shardID
            return AppEnvironmentOverride(base: shared, baseURL: baseURL, shardID: shardID)
        }

        return .shared
    }

    /// This method returns an `AppEnvironmentOverride` using the given `baseURL`s host if it
    /// doesn't match the one on `AppEnvironment.shared`.
    static func resolved(for baseURL: URL?) -> AppEnvironment {
        guard
            let baseURL,
            let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else { return .shared }
        return resolved(for: components)
    }

    /// This only works for overridden environments
    func courseShardIdOverridden(with info: [String: Any]?) -> Self {
        if let shardID = info?[Self.courseShardIdOverrideUserInfoKey] as? String,
           let envOverride = self as? AppEnvironmentOverride {
            envOverride.resetCourseShardIDOverride(shardID)
        }
        return self
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
