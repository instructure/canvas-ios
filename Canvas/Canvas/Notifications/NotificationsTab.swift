//
//  NotificationsTab.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 3/21/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import Foundation
import TechDebt


func NotificationsTab() -> UIViewController {
    let vc: UIViewController
    
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
        vc = CBINotificationSplitViewController()
    } else {
        vc = CBINotificationListViewController()
    }
    
    let title = NSLocalizedString("Notifications", comment: "Notifications tab title")
    
    vc.navigationItem.title = title
    
    vc.tabBarItem.title = title
    vc.tabBarItem.image = UIImage.techDebtImageNamed("icon_notifications_tab")
    vc.tabBarItem.selectedImage = UIImage.techDebtImageNamed("icon_notifications_tab_selected")
    
    return UINavigationController(rootViewController: vc);
}