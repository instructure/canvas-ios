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

import Foundation
import TechDebt
import CanvasCore
import Core

public func ToDoTabViewController(session: Session) throws -> UIViewController {
        
    let list = try ToDoListViewController(session: session)

    let split = HelmSplitViewController()
    split.preferredDisplayMode = .allVisible
    let masterNav = UINavigationController(rootViewController: list)
    let detailNav = UINavigationController()
    detailNav.view.backgroundColor = UIColor.white
    masterNav.navigationBar.useGlobalNavStyle()
    detailNav.navigationBar.useGlobalNavStyle()
    split.viewControllers = [masterNav, detailNav]

    let title = NSLocalizedString("To Do", comment: "Title of the Todo screen")
    list.navigationItem.title = title
    split.tabBarItem.title = title
    split.tabBarItem.image = .icon(.todo)
    split.tabBarItem.selectedImage = .icon(.todoSolid)
    split.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
    return split
}
