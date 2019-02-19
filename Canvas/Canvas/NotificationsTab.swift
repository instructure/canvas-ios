//
// Copyright (C) 2016-present Instructure, Inc.
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
    vc.tabBarItem.image = UIImage(named: "icon_notifications_tab")
    vc.tabBarItem.selectedImage = UIImage(named: "icon_notifications_tab_selected")
    
    return UINavigationController(rootViewController: vc);
}