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

public class UnreadMessages: NSObject {
    public static let count = MutableProperty<Int>(0)
    
    @objc
    public func updateUnreadCount(_ count: NSNumber) {
        UnreadMessages.count.value = count.intValue
    }
}
