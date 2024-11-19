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

public class Analytics: NSObject {
    public static var shared: Analytics = Analytics()

    public weak var handler: AnalyticsHandler?

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

    public static var analyticsBaseUrl: String {
        guard let session = AppEnvironment.shared.currentSession else {
            return ""
        }
        return session.baseURL.absoluteString
    }

    public static var analyticsBaseUrl: String {
        guard let session = AppEnvironment.shared.currentSession else {
            return ""
        }
        return session.baseURL.absoluteString
    }
}
