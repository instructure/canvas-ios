//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

extension UIViewController {

    /// This property returns a human readable name for the given view controller.
    /// In case of split view controllers and navigation controllers this method
    /// tries to extract the wrapped view controller and returns the name of that.
    /// If a view controller hosts a SwiftUI view then the name of the view will be returned.
    public var loggableName: String {
        let splitViewContent: UIViewController = {
            if let split = self as? UISplitViewController {
                return split.viewControllers.first ?? split
            } else {
                return self
            }
        }()
        let navViewContent: UIViewController = {
            if let nav = splitViewContent as? UINavigationController {
                return nav.topViewController ?? nav
            } else {
                return self
            }
        }()

        var name = String(describing: type(of: navViewContent))

        // Extracts "Type" from a pattern of CoreHostingController<Type>
        if let genericsStart = name.firstIndex(of: "<") {
            name = name.suffix(from: name.index(after: genericsStart)).replacingOccurrences(of: ">", with: "")
        }

        return name
    }
}

extension Optional where Wrapped == UIViewController {

    public var loggableName: String {
        guard let self else {
            return "unknown"
        }

        return self.loggableName
    }
}
