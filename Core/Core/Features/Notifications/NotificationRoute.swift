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

import UserNotifications

extension UNNotificationContent {
    public static let RouteURLKey = "com.instructure.core.router.notification-url"
}

extension UNNotificationRequest {

    public var routeURL: URL? {
        content.userInfo.routeURL
    }
}

public extension Dictionary where Key == AnyHashable {

    var routeURL: URL? {
        // Handle local notifications we know about first
        if let route = self[UNNotificationContent.RouteURLKey] as? String {
            return URL(string: route)
        }
        if let url = self["html_url"] as? String {
            return URL(string: url).fixBetaURL()
        }
        return nil
    }
}

private extension Optional where Wrapped == URL {

    // In beta, a push notification's url may point to prod. Fix it to point to beta.
    func fixBetaURL() -> URL? {
        guard
            let baseURL = AppEnvironment.shared.currentSession?.baseURL,
            baseURL.host?.contains(".beta") == true,
            baseURL.host?.replacingOccurrences(of: ".beta", with: "") == self?.host,
            var components = self.map({ URLComponents.parse($0) })
        else { return self }
        components.host = baseURL.host
        return components.url ?? self
    }
}
