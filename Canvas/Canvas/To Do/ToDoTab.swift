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
    
    

import Foundation



import TechDebt
import CanvasCore

public func ToDoTabViewController(session: Session, route: @escaping (UIViewController, URL)->()) throws -> UIViewController {
        
    let list = try! ToDoListViewController(session: session, route: route)

    let split = SplitViewController()
    split.preferredDisplayMode = .allVisible
    let masterNav = UINavigationController(rootViewController: list)
    let detailNav = UINavigationController()
    detailNav.view.backgroundColor = UIColor.white
    masterNav.applyDefaultBranding()
    detailNav.applyDefaultBranding()
    split.viewControllers = [masterNav, detailNav]

    let title = NSLocalizedString("To Do", comment: "Title of the Todo screen")
    list.navigationItem.title = title
    split.tabBarItem.title = title
    split.tabBarItem.image = .icon(.todo)
    return split
}
