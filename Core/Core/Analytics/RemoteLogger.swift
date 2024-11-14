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

public protocol RemoteLogHandler: AnyObject {
    func handleError(_ name: String, reason: String)
    func handleBreadcrumb(_ name: String)
}

/// This entity encapsulates methods that log debug data for developers to make crash / error debugging easier.
public struct RemoteLogger {
    public static var shared: RemoteLogger = RemoteLogger()

    public weak var handler: RemoteLogHandler?

    #if DEBUG
    /// If this property is true, then in addition to reporting to the analytics handler, events are also printed to the console.
    public var logToConsole = false
    #endif

    public init() {}

    /// Use this method to collect routing events which will be uploaded when a crash happens
    /// so we'll be better able to locate and reproduce the crash based on the routes log.
    public func logBreadcrumb(
        route: String,
        viewController: UIViewController? = nil
    ) {
        let message = "Routing to: \(route) (\(viewController.developerAnalyticsName))"

        #if DEBUG
            if logToConsole {
                print(message)
            }
        #endif

        handler?.handleBreadcrumb(message)
    }

    /// Use this method to report errors to Crashlytics.
    ///
    /// - parameters:
    ///    - name: The name of the error type. Errors with the same name will be grouped on Crashlytics to a single error entry.
    ///    - reason: The arbitrary error reason.
    public func logError(name: String, reason: String? = nil) {
        let reason = reason ?? "Unknown reason."

        #if DEBUG
            if logToConsole {
                print("\(name) - \(reason)")
            }
        #endif

        handler?.handleError(name, reason: reason)
    }
}
