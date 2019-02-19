//
// Copyright (C) 2018-present Instructure, Inc.
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

extension UIView {
    public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    public func pin(inside parent: UIView, leading: CGFloat? = 0, trailing: CGFloat? = 0, top: CGFloat? = 0, bottom: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let leading = leading {
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: leading).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: trailing).isActive = true
        }
        if let top = top {
            topAnchor.constraint(equalTo: parent.topAnchor, constant: top).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: bottom).isActive = true
        }
    }

    /**
     Uses VFL (visual format language) string to add constraints.  This method adds two views by default to the
     views parameter dictionary. `view` which is the view you are calling this method from and `superview`.  These
     two views do not need to be passed in as part of the `views` dictionary.
     - Parameter VFL: visual format language to add constraints referencing view.  (i.e. `"V:|-(5)-[view]-(5)-|"`)
     - Parameter views:   Connecting views, already contains the view you call this method
     - Parameter metrics: variables to be substituted in VFL string
     - Returns: An optional array of NSLayoutConstraints
     */
    @discardableResult
    public func addConstraintsWithVFL(_ VFL: String, views: [String: UIView]? = nil, metrics: [String: Any]? = nil) -> [NSLayoutConstraint]? {
        if let superview = superview {
            translatesAutoresizingMaskIntoConstraints = false
            var connectingViews = ["view": self, "superview": superview]
            views?.forEach { (k, v) in  connectingViews[k] = v }
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: VFL, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: connectingViews)
            superview.addConstraints(constraints)
            return constraints
        } else {
            return nil
        }
    }

    public func pinToLeftAndRightOfSuperview() {
        if let superview = superview {
            pin(inside: superview, leading: 0, trailing: 0, top: nil, bottom: nil)
        }
    }

    public func pinToTopAndBottomOfSuperview() {
        if let superview = superview {
            pin(inside: superview, leading: nil, trailing: nil, top: 0, bottom: 0)
        }
    }
}
