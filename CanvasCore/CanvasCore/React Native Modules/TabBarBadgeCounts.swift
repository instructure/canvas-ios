//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CanvasKit
import ReactiveSwift

let MaxTabBarCount = 99

public class TabBarBadgeCounts: NSObject {
    public static let unreadMessageCountString = MutableProperty<String?>(nil)
    public static let todoListCountString = MutableProperty<String?>(nil)
    public static let applicationIconBadgeNumber = MutableProperty<Int>(0)
    public static var unreadMessageCount = 0 {
        didSet {
            if unreadMessageCount > MaxTabBarCount {
                unreadMessageCountString.value = NSLocalizedString("99+", tableName: nil, bundle: .core, value: "99+", comment: "more than 99")
            } else if unreadMessageCount > 0 {
                unreadMessageCountString.value = NumberFormatter.localizedString(from: NSNumber(value: unreadMessageCount), number: .none)
            } else {
                unreadMessageCountString.value = nil
            }
            updateApplicationIconBadgeNumber()
        }
    }
    public static var todoListCount = 0 {
        didSet {
            if todoListCount > MaxTabBarCount {
                todoListCountString.value = NSLocalizedString("99+", tableName: nil, bundle: .core, value: "99+", comment: "more than 99")
            } else if todoListCount > 0 {
                todoListCountString.value = NumberFormatter.localizedString(from: NSNumber(value: todoListCount), number: .none)
            } else {
                todoListCountString.value = nil
            }
            updateApplicationIconBadgeNumber()
        }
    }
    
    @objc
    public func updateUnreadMessageCount(_ count: NSNumber) {
        TabBarBadgeCounts.unreadMessageCount = count.intValue
    }
    
    @objc
    public func updateTodoListCount(_ count: NSNumber) {
        TabBarBadgeCounts.todoListCount = count.intValue
    }
    
    static func updateApplicationIconBadgeNumber() {
        let count = (TabBarBadgeCounts.unreadMessageCount + TabBarBadgeCounts.todoListCount)
        TabBarBadgeCounts.applicationIconBadgeNumber.value = min(count, MaxTabBarCount)
    }
}
