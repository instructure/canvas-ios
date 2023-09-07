//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import SwiftUI

protocol Navigatable: View {
     var navigationController: UINavigationController? { get }
}

extension Navigatable {
    var navigationController: UINavigationController? {
        guard let topViewController = AppEnvironment.shared.topViewController as? UITabBarController else {
            return nil
        }

        if let navigationController = topViewController.viewControllers?.first?.children.last?.children.first as? UINavigationController {
            return navigationController
        }

        if let helmSplitViewController = topViewController.viewControllers?.first?.children.last?.children.first as? UISplitViewController,
           let navigationController = helmSplitViewController.masterNavigationController {
            return navigationController
        }

        if let navigationController = topViewController.selectedViewController?.children.first as? UINavigationController {
            return navigationController
        }

       return nil
   }
}
