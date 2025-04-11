//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Core
import UserNotifications

public class MockUserNotificationCenter: UserNotificationCenterProtocol {
    public var requests: [UNNotificationRequest] = []
    public var error: Error?
    public var authorized = true
    public var authError: Error?
    public var badgeCount: Int?
    public var mockBadgeError: (any Error)?
    public weak var delegate: UNUserNotificationCenterDelegate?

    public private(set) var authorizationRequestOptions: UNAuthorizationOptions?

    public init() {}

    public func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        authorizationRequestOptions = options
        completionHandler(authorized, authError)
    }

    public func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        removePendingNotificationRequests(withIdentifiers: [request.identifier])
        requests.append(request)
        completionHandler?(error)
    }

    public func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        completionHandler(requests)
    }

    public func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        requests = requests.filter { !identifiers.contains($0.identifier) }
    }

    public func setBadgeCount(_ newBadgeCount: Int, withCompletionHandler completionHandler: (((any Error)?) -> Void)?) {
        badgeCount = newBadgeCount
        completionHandler?(mockBadgeError)
    }
}
