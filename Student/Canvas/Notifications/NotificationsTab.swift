//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit
import Foundation
import CanvasCore
import Core

func NotificationsTab() -> UIViewController {
    let title = NSLocalizedString("Notifications", comment: "Notifications tab title")
    let activityStream: UIViewController = ActivityStreamViewController.create()
    
    let split = HelmSplitViewController()
    split.preferredDisplayMode = .allVisible
    let masterNav = UINavigationController(rootViewController: activityStream)
    let detailNav = UINavigationController()
    masterNav.navigationBar.useGlobalNavStyle()
    detailNav.navigationBar.useGlobalNavStyle()
    detailNav.view.backgroundColor = .named(.backgroundLightest)
    split.viewControllers = [masterNav, detailNav]
    
    activityStream.navigationItem.title = title
    split.tabBarItem.title = title
    split.tabBarItem.image = .icon(.alerts, .line)
    split.tabBarItem.selectedImage = .icon(.alerts, .solid)
    split.tabBarItem.accessibilityIdentifier = "TabBar.notificationsTab"
    return split
}
