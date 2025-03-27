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

    fileprivate init(base: AppEnvironment, baseURL: URL) {
        self.base = base
        self.baseURL = baseURL
        super.init()
    }

    private lazy var apiOverride: API = {
        API(currentSession, baseURL: baseURL)
    }()

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
                baseURL: baseURL, // This important to authenticate requests
                expiresAt: cSession.expiresAt,
                lastUsedAt: cSession.lastUsedAt,
                locale: cSession.locale,
                masquerader: cSession.masquerader,
                refreshToken: cSession.refreshToken,
                userAvatarURL: cSession.userAvatarURL,
                userID: cSession.userID,
                userName: cSession.userName,
                userEmail: cSession.userEmail,
                oauthType: cSession.oauthType,
                isFakeStudent: cSession.isFakeStudent
            )
        }
        set {}
    }
}

extension AppEnvironment {

    /// This method returns an `AppEnvironmentOverride` using the given `url`s host if it
    /// doesn't match the one on `AppEnvironment.shared`.
    static func resolved(for url: URLComponents) -> AppEnvironment {
        if let host = url.host, host != shared.api.baseURL.host(),
           let baseURL = url.with(scheme: shared.api.baseURL.scheme).url?.apiBaseURL {
            return AppEnvironmentOverride(base: shared, baseURL: baseURL)
        }

        return .shared
    }
}

// MARK: - Utils

private extension URLComponents {
    func with(scheme: String?) -> Self {
        var copy = self
        copy.scheme = scheme
        return copy
    }
}
