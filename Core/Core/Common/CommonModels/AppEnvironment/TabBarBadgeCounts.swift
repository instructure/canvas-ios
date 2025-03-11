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

import UserNotifications
import UIKit

public class TabBarBadgeCounts: NSObject {
    public static var notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current() {
        didSet { updateApplicationIconBadgeNumber() }
    }
    public static weak var messageItem: UITabBarItem? {
        didSet { updateUnreadMessageCount() }
    }
    public static weak var todoItem: UITabBarItem? {
        didSet { updateTodoListCount() }
    }

    @objc public static var unreadMessageCount: UInt = 0 {
        didSet {
            updateUnreadMessageCount()
            updateApplicationIconBadgeNumber()
        }
    }
    @objc public static var todoListCount: UInt = 0 {
        didSet {
            updateTodoListCount()
            updateApplicationIconBadgeNumber()
        }
    }

    private static func updateApplicationIconBadgeNumber() {
        let count = Int(unreadMessageCount + todoListCount)
        notificationCenter.setBadgeCount(count) { _ in }
    }

    private static func updateUnreadMessageCount() {
        messageItem?.badgeValue = unreadMessageCount <= 0 ? nil :
            NumberFormatter.localizedString(from: NSNumber(value: unreadMessageCount), number: .none)
    }

    private static func updateTodoListCount() {
        todoItem?.badgeValue = todoListCount <= 0 ? nil :
            NumberFormatter.localizedString(from: NSNumber(value: todoListCount), number: .none)
    }
}
