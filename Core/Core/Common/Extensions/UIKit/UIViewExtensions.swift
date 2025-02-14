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

import UIKit

public protocol ViewLoader {}
extension UIView: ViewLoader {}
extension ViewLoader where Self: UIView {
    /// Returns a newly initialized view controller.
    /// This can assume the nib name matches the type name and the bundle contains the type.
    public static  func loadFromXib(nibName name: String = String(describing: Self.self)) -> Self {
        guard let view = Bundle(for: self).loadNibNamed(name, owner: self, options: nil)?.first as? Self else {
            fatalError("Could not create \(name) from a xib.")
        }
        return view
    }

    @discardableResult
    public func loadFromXib(nibName name: String = String(describing: Self.self)) -> UIView {
        guard let view = Bundle(for: Self.self).loadNibNamed(name, owner: self, options: nil)?.first as? UIView else {
            fatalError("Could not load first view from \(name) xib.")
        }
        addSubview(view)
        view.pin(inside: self)
        return view
    }
}

extension UIView {
    /** This property returns the View's ViewController if there's one. */
    var viewController: UIViewController? {
        findNextResponder(type: UIViewController.self, nextResponder: self)
    }

    func findNextResponder<T>(type: T.Type, nextResponder: UIResponder?) -> T? {
        guard nextResponder != nil else {
            return nil
        }
        guard let nextResponder = nextResponder as? T else {
            return findNextResponder(type: type, nextResponder: nextResponder?.next)
        }
        return nextResponder
    }

    /** This method will update the receiver view's frame to fully keep it inside its parent view. */
    public func restrictFrameInsideSuperview() {
        guard let parentSize = superview?.frame.size else { return }
        var newFrame = frame
        newFrame.origin.x = max(0, newFrame.origin.x)
        newFrame.origin.x = min(newFrame.origin.x, parentSize.width - newFrame.size.width)
        newFrame.origin.y = max(0, newFrame.origin.y)
        newFrame.origin.y = min(newFrame.origin.y, parentSize.height - newFrame.size.height)
        frame = newFrame
    }

    public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    public func pin(inside parent: UIView?, leading: CGFloat? = 0, trailing: CGFloat? = 0, top: CGFloat? = 0, bottom: CGFloat? = 0) {
        guard let parent = parent else { return }
        translatesAutoresizingMaskIntoConstraints = false
        if let leading = leading {
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: leading).isActive = true
        }
        if let trailing = trailing {
            parent.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing).isActive = true
        }
        if let top = top {
            topAnchor.constraint(equalTo: parent.topAnchor, constant: top).isActive = true
        }
        if let bottom = bottom {
            parent.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom).isActive = true
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

    public func constraintsAffecting(view: UIView) -> [NSLayoutConstraint] {
        constraints.filter { constraint in
            constraint.firstItem as? NSObject == view || constraint.secondItem as? NSObject == view
        }
    }

    public var isHorizontallyCompact: Bool {
        traitCollection.horizontalSizeClass == .compact
    }
}
