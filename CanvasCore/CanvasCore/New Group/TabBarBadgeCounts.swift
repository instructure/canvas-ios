//
//  UnreadCount.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 10/9/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation
import CanvasKit
import ReactiveSwift

public class TabBarBadgeCounts: NSObject {
    public static let unreadMessageCount = MutableProperty<Int>(0)
    public static let todoListCount = MutableProperty<Int>(0)
    public static let applicationIconBadgeNumber = MutableProperty<Int>(0)
    
    @objc
    public func updateUnreadMessageCount(_ count: NSNumber) {
        TabBarBadgeCounts.unreadMessageCount.value = count.intValue
        updateApplicationIconBadgeNumber()
    }
    
    @objc
    public func updateTodoListCount(_ count: NSNumber) {
        TabBarBadgeCounts.todoListCount.value = count.intValue
        updateApplicationIconBadgeNumber()
    }
    
    func updateApplicationIconBadgeNumber() {
        TabBarBadgeCounts.applicationIconBadgeNumber.value =
            (TabBarBadgeCounts.unreadMessageCount.value +
             TabBarBadgeCounts.todoListCount.value)
    }
}
