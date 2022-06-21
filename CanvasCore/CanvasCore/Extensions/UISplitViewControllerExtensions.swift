//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import Core

public extension UISplitViewController {
    var detailNavigationController: StyledNavigationController? {
        guard viewControllers.count > 1 else { return nil }
        return viewControllers.last as? StyledNavigationController
    }

    var masterTopViewController: UIViewController? {
        masterNavigationController?.topMostViewController()
    }

    var detailTopViewController: UIViewController? {
        detailNavigationController?.topMostViewController()
    }

    func sourceController(moduleName: String) -> UIViewController? {
        if (detailTopViewController as? HelmModule)?.moduleName == moduleName {
            return detailTopViewController
        }

        if (masterTopViewController as? HelmModule)?.moduleName == moduleName {
            return masterTopViewController
        }
        return nil
    }
}
