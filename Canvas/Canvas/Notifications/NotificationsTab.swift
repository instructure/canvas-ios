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
import CanvasCore

func NotificationsTab(session: Session) throws -> UIViewController {
    let title = NSLocalizedString("Notifications", comment: "Notifications tab title")
    let activityStream = try ActivityStreamTableViewController(session: session, route: { viewController, url in
        Router.shared().route(from: viewController, to: url)
    })
    activityStream.title = title
    
    let split = SplitViewController()
    split.preferredDisplayMode = .allVisible
    let masterNav = UINavigationController(rootViewController: activityStream)
    let detailNav = UINavigationController()
    masterNav.applyDefaultBranding()
    detailNav.applyDefaultBranding()
    detailNav.view.backgroundColor = UIColor.white
    split.viewControllers = [masterNav, detailNav]
    
    activityStream.navigationItem.title = title
    split.tabBarItem.title = title
    split.tabBarItem.image = .icon(.notification)
    return split
}
