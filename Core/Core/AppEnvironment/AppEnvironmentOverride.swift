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

import Foundation
import CoreData

public final class AppEnvironmentOverride: AppEnvironment {

    let base: AppEnvironment
    let baseURL: URL

    private var session: LoginSession? {
        guard let cSession = base.currentSession else { return nil }

        return LoginSession(
            accessToken: cSession.accessToken,
            baseURL: baseURL,
            expiresAt: cSession.expiresAt,
            lastUsedAt: cSession.lastUsedAt,
            locale: cSession.locale,
            masquerader: cSession.masquerader,
            refreshToken: cSession.refreshToken,
            userAvatarURL: cSession.userAvatarURL,
            userID: cSession.userID,
            userName: cSession.userName,
            userEmail: cSession.userEmail,
            clientID: cSession.clientID,
            clientSecret: cSession.clientSecret,
            isFakeStudent: cSession.isFakeStudent
        )
    }

    fileprivate init(base: AppEnvironment, baseURL: URL) {
        self.base = base
        self.baseURL = baseURL
        super.init()
    }

    private lazy var apiOverride: API = {
        API(session, baseURL: baseURL)
    }()

    private lazy var routerOverride: RouterOverride = {
        RouterOverride(env: self, base: base.router, baseURL: baseURL)
    }()

    public override var app: AppEnvironment.App? {
        get { base.app }
        set {}
    }

    public override var router: Router {
        get { routerOverride }
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

    public override var currentSession: LoginSession? {
        get { session }
        set {}
    }
}

private class RouterOverride: Router {

    let baseURL: URL
    let base: Router
    unowned let env: AppEnvironmentOverride

    init(env: AppEnvironmentOverride, base: Router, baseURL: URL) {
        self.env = env
        self.base = base
        self.baseURL = baseURL
        super.init(routes: [])
    }

    private func mergedInfo(with otherInfo: [String: Any]?) -> [String: Any]? {
        let baseInfo: [String: Any] = ["baseURL": baseURL]
        guard let otherInfo else { return baseInfo }
        return baseInfo.merging(otherInfo, uniquingKeysWith: { $1 })
    }

    override func route(to url: URLComponents, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = DefaultRouteOptions) {
        let info = mergedInfo(with: userInfo)
        base.route(to: url, userInfo: info, from: from, options: options)
    }

    override func isRegisteredRoute(_ url: URLComponents) -> Bool {
        base.isRegisteredRoute(url)
    }

    override func template(for url: URLComponents) -> String? {
        base.template(for: url)
    }

    override func match(_ url: URLComponents, userInfo: [String: Any]? = nil) -> UIViewController? {
        let info = mergedInfo(with: userInfo)
        return base.match(url, userInfo: info)
    }

    override func show(_ view: UIViewController, from: UIViewController, options: RouteOptions = DefaultRouteOptions, analyticsRoute: String? = "/unknown", completion: (() -> Void)? = nil) {
        base.show(
            view,
            from: from,
            options: options,
            analyticsRoute: analyticsRoute,
            completion: completion
        )
    }

    override func pop(from: UIViewController) {
        base.pop(from: from)
    }

    override func popToRoot(from: UIViewController) {
        base.popToRoot(from: from)
    }

    override func dismiss(_ view: UIViewController, completion: (() -> Void)? = nil) {
        base.dismiss(view, completion: completion)
    }
}

public extension AppEnvironment {

    static func resolved(for url: URLComponents, with info: [String: Any]?) -> AppEnvironment {
        // This is still important to support internal links to assignments tab
        if let baseURL = info?["baseURL"] as? URL, baseURL != shared.api.baseURL {
            return AppEnvironmentOverride(base: shared, baseURL: baseURL)
        }

        // Only check for the host part, if not match, recreate base URL using URL scheme of
        // the currentSession base URL.
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
