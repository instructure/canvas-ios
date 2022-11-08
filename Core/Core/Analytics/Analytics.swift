//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public protocol AnalyticsHandler: AnyObject {
    func handleEvent(_ name: String, parameters: [String: Any]?)
}

@objc(Analytics)
public class Analytics: NSObject {
    @objc public static var shared: Analytics = Analytics()
    public weak var handler: AnalyticsHandler?

    @objc
    public func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        handler?.handleEvent(name, parameters: parameters)
    }

    public func logError(_ name: String, description: String? = nil) {
        handler?.handleEvent(name, parameters: ["error": description ?? ""])
    }

    @objc(logScreenView:viewController:)
    public func logScreenView(route: String, viewController: UIViewController? = nil) {
        handler?.handleEvent("screen_view", parameters: [
            "application": Self.analyticsAppName,
            "screen_name": route,
            "screen_class": Self.analyticsClassName(for: viewController),
        ])
    }

    public func logSession(_ session: LoginSession) {
        var defaults = SessionDefaults(sessionID: session.uniqueID)
        let tokenExpires = session.expiresAt != nil
        if defaults.tokenExpires == nil || defaults.tokenExpires != tokenExpires {
            let event = tokenExpires ? "auth_expiring_token" : "auth_forever_token"
            logEvent(event)
            defaults.tokenExpires = tokenExpires
        }
    }

    public static var analyticsAppName: String {
        guard let app = AppEnvironment.shared.app else {
            return "unknown"
        }
        return app.rawValue
    }

    public static func analyticsClassName(for viewController: UIViewController?) -> String {
        guard let viewController = viewController else {
            return "unknown"
        }

        let splitViewContent: UIViewController = {
            if let split = viewController as? UISplitViewController {
                return split.viewControllers.first ?? split
            } else {
                return viewController
            }
        }()
        let navViewContent: UIViewController = {
            if let nav = splitViewContent as? UINavigationController {
                return nav.topViewController ?? nav
            } else {
                return viewController
            }
        }()

        var name = String(describing: type(of: navViewContent))

        // Extracts "Type" from a pattern of CoreHostingController<Type>
        if let genericsStart = name.firstIndex(of: "<") {
            name = name.suffix(from: name.index(after: genericsStart)).replacingOccurrences(of: ">", with: "")
        }

        return name
    }
}
