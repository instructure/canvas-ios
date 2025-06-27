//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class CoreWebViewAccessibilityHelper {

    /// Toggles exclusive VoiceOver accessibility for the given view and its hierarchy.
    /// When isExclusive is true, only the given view and its descendants are accessible.
    /// When false, restores accessibility to all siblings and parent containers.
    func setExclusiveAccessibility(
        for view: UIView,
        isExclusive: Bool,
        viewController: UIViewController?
    ) {
        setSiblingsHidden(of: view, hidden: isExclusive)
        viewController?.tabBarController?.tabBar.accessibilityElementsHidden = isExclusive
        viewController?.navigationController?.navigationBar.accessibilityElementsHidden = isExclusive
    }

    private func setSiblingsHidden(of view: UIView, hidden: Bool) {
        guard let parent = view.superview else { return }
        for sibling in parent.subviews where sibling !== view {
            sibling.accessibilityElementsHidden = hidden
        }
        setSiblingsHidden(of: parent, hidden: hidden)
    }
}
