//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import Core

extension UINavigationController {
    // Sets the barTintColor on self as well as a detail in a split view controller situation
    public func syncBarTintColor(_ color: UIColor?) {
        self.navigationBar.barTintColor = color
        syncStyles()
    }
    
    // Looks at what is in the master, if in split view, and applies what master has to detail
    public func syncStyles() {
        guard let svc = self.splitViewController else { return }
        guard let master = svc.masterNavigationController else { return }
        guard let detail = svc.detailNavigationController else { return }
        detail.navigationBar.barTintColor = master.navigationBar.barTintColor
        detail.navigationBar.tintColor = master.navigationBar.tintColor
        detail.navigationBar.shadowImage = master.navigationBar.shadowImage
        detail.navigationBar.isTranslucent = master.navigationBar.isTranslucent
        detail.navigationBar.barStyle = master.navigationBar.barStyle
        detail.navigationBar.titleTextAttributes = master.navigationBar.titleTextAttributes
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        visibleViewController?.supportedInterfaceOrientations ?? .all
    }

    open override var shouldAutorotate: Bool {
        visibleViewController?.shouldAutorotate ?? true
    }
}
