//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

extension UITableViewHeaderFooterView {
    @objc dynamic var hasBorderSeparators: Bool {
        get {
            subviews.contains { $0 is BorderView }
        }
        set {
            guard hasBorderSeparators != newValue else {
                return
            }
            if newValue {
                addSubview(BorderView(frame: bounds, topEdge: true))
                addSubview(BorderView(frame: bounds, topEdge: false))
            } else {
                for view in subviews where view is BorderView {
                    view.removeFromSuperview()
                }
            }
        }
    }

    class BorderView: UIView {
        required init(frame: CGRect, topEdge: Bool = true) {
            var newFrame = frame
            if !topEdge {
                newFrame.origin.y += frame.height
            }
            // stick out from top edge for that pixel-perfect overlap
            newFrame.origin.y -= 0.5
            newFrame.size.height = 0.5
            super.init(frame: newFrame)

            backgroundColor = .opaqueSeparator
            autoresizingMask = [.flexibleWidth, topEdge ? .flexibleBottomMargin : .flexibleTopMargin]
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
