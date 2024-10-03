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
    func handleScreenView(screenName: String, screenClass: String, application: String)
    func handleError(_ name: String, reason: String)
    func handleEvent(_ name: String, parameters: [String: Any]?)
}

@objc(Analytics)
public class Analytics: NSObject {
    @objc public static var shared: Analytics = Analytics()
    public weak var handler: AnalyticsHandler?
    #if DEBUG
    public var logScreenViewToConsole = false
    #endif

    /**
     Use this method to collect screen view events which will be uploaded when a crash happens
     so we'll be better be able to locate and reproduce the crash.
     */
    @objc(logScreenView:viewController:)
    public func logScreenView(route: String, viewController: UIViewController? = nil) {
        #if DEBUG
        if logScreenViewToConsole {
            print("ScreenView: \(route) (\(Self.analyticsClassName(for: viewController)))")
        }
        #endif
        handler?.handleScreenView(screenName: route,
                                  screenClass: Self.analyticsClassName(for: viewController),
                                  application: Self.analyticsAppName)
    }

    /**
     Use this method to report errors to Crashlytics.

     - parameters:
        - name: The name of the error type. Errors with the same name will be grouped on Crashlytics to a single error entry.
        - reason: The arbitrary error reason.
     */
    public func logError(name: String, reason: String? = nil) {
        handler?.handleError(name, reason: reason ?? "Unknown reason.")
    }

    /**
     This method is mainly used to track user and application actions for usage statistics.
     */
    @objc
    public func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        handler?.handleEvent(name, parameters: parameters)
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
