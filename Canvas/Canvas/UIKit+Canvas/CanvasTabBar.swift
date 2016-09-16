//
//  CanvasTabBar.swift
//  iCanvas
//
//  Created by Miles Wright on 8/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import NotificationKit

class CanvasTabBar: UITabBarController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationKitController.registerForPushNotificationsIfAppropriate(self)
    }
}