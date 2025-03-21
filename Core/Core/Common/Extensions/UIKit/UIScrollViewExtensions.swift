//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

extension UIScrollView {
    /// Whether or not the scroll view has reached the bottom using a threshold.
    ///
    /// The default `threshold` is 60.
    public func isBottomReached(threshold: CGFloat = 60) -> Bool {
        return contentOffset.y >= contentSize.height - frame.size.height - threshold
    }

    /// Get a ratio for contentOffset based on current orientation that can then be used after device rotation
    /// to set contentOffset
    public var contentOffsetRatio: CGPoint {
        let w = contentSize.width
        let h = contentSize.height
        let centerX = (contentOffset.x + (frame.size.width / 2.0)) / w
        let centerY = (contentOffset.y + (frame.size.height / 2.0)) / h
        return CGPoint(x: centerX, y: centerY)
    }

    /// Scroll to the textfield (`view`) when the keyboard is shown
    /// Must be used in conojuction with UITextFieldDelegate and Keyboard notifications
    public func scrollToView(view: UIView?, keyboardRect: CGRect) {
        var visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: bounds.size.width, height: bounds.size.height)
        var viewRect: CGRect = CGRect.zero
        visibleRect.size.height -= keyboardRect.height

        if let view = view, let superview = view.superview {
            viewRect = convert(view.frame, from: superview)
        }

        if !visibleRect.contains(viewRect) {
            let yOffset = (viewRect.size.height < visibleRect.size.height) ? (viewRect.origin.y) - (visibleRect.size.height - viewRect.size.height) : viewRect.origin.y
            setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
        }
    }
}
