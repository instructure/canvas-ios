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

public protocol DeveloperAnalyticsHandler: AnyObject {
    func handleError(_ name: String, reason: String)
    func handleBreadcrumb(_ name: String)
}

public struct DeveloperAnalytics {
    public static var shared: DeveloperAnalytics = DeveloperAnalytics()

    public weak var handler: DeveloperAnalyticsHandler?

    #if DEBUG
    public var logScreenViewToConsole = true
    #endif

    public init() {}

    /// Use this method to collect screen view events which will be uploaded when a crash happens
    /// so we'll be better be able to locate and reproduce the crash.
    public func logBreadcrumb(
        route: String,
        viewController: UIViewController? = nil
    ) {
        #if DEBUG
            if logScreenViewToConsole {
                print("Routing to: \(route) (\(Self.analyticsClassName(for: viewController)))")
            }
        #endif

        handler?.handleBreadcrumb("Routing to: \(route) (\(Self.analyticsClassName(for: viewController)))")
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
