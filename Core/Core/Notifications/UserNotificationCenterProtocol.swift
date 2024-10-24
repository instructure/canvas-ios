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

import Combine
import UserNotifications

/**
 This is a wrapper protocol for `UNUserNotificationCenter` to make classes using it testable.
 */
public protocol UserNotificationCenterProtocol: AnyObject {
    var delegate: UNUserNotificationCenterDelegate? { get set }

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func setBadgeCount(_ newBadgeCount: Int, withCompletionHandler completionHandler: (((any Error)?) -> Void)?)
}

public enum NotificationCenterError: Error, Equatable {
    case noPermission
}

public extension UserNotificationCenterProtocol {

    func requestAuthorization(options: UNAuthorizationOptions = []) -> Future<Void, NotificationCenterError> {
        Future { [self] promise in
            requestAuthorization(options: options) { granted, error in
                if error != nil {
                    return promise(.failure(.noPermission))
                }

                promise(granted ? .success(()) : .failure(.noPermission))
            }
        }
    }

    func add(_ request: UNNotificationRequest) -> Future<Void, Error> {
        Future<Void, Error> { [self] promise in
            add(request) { error in
                if let error {
                    Analytics.shared.logError(name: "Failed to schedule local notification",
                                              reason: error.localizedDescription)
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    func getPendingNotificationRequests() -> Future<[UNNotificationRequest], Never> {
        Future { [self] promise in
            getPendingNotificationRequests { notifications in
                promise(.success(notifications))
            }
        }
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) -> Future<Void, Never> {
        Future { [self] promise in
            removePendingNotificationRequests(withIdentifiers: identifiers)
            promise(.success(()))
        }
    }
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {}
