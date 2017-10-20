//
//  UIApplication+Reactive.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 10/17/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import UIKit
import ReactiveSwift

extension Reactive where Base: UIApplication {
    /// Sets the badge for the app icon
    public var applicationIconBadgeNumber: BindingTarget<Int> {
        return makeBindingTarget { $0.applicationIconBadgeNumber = $1 }
    }
}
