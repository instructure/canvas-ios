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

public protocol ViewControllerLoader {}
extension UIViewController: ViewControllerLoader {}
extension ViewControllerLoader where Self: UIViewController {
    /// Instantiates and returns the view controller.
    /// This can assume that the identifier matches the type name.
    public static func loadFromStoryboard(withIdentifier identifier: String = String(describing: Self.self)) -> Self {
        let storyboard = UIStoryboard(name: identifier, bundle: Bundle(for: self))
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? Self else {
            fatalError("Could not create \(identifier) from a storyboard.")
        }
        return viewController
    }

    /// Returns a newly initialized view controller.
    /// This can assume the nib name matches the type name and the bundle contains the type.
    public static func loadFromXib(nibName name: String = String(describing: Self.self)) -> Self {
        return Self.init(nibName: name, bundle: Bundle(for: self))
    }
}

extension UIViewController {
    public enum NavigationItemSide {
        case right
        case left
    }

    public func addNavigationButton(_ button: UIBarButtonItem, side: NavigationItemSide) {
        switch side {
        case .right:
            navigationItem.rightBarButtonItems = [button] + (navigationItem.rightBarButtonItems ?? [])
        case .left:
            navigationItem.leftBarButtonItems = [button] + (navigationItem.leftBarButtonItems ?? [])
        }
    }

    public func addCancelButton(side: NavigationItemSide = .right) {
        addDismissBarButton(.cancel, side: side)
    }

    public func addDoneButton(side: NavigationItemSide = .right) {
        addDismissBarButton(.done, side: side)
    }

    public func addDismissBarButton(_ barButtonSystemItem: UIBarButtonItem.SystemItem, side: NavigationItemSide) {
        let button = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: self, action: #selector(dismissDoneButton))
        addNavigationButton(button, side: side)
    }

    @objc func dismissDoneButton() {
        dismiss(animated: true, completion: nil)
    }

    public func topMostViewController() -> UIViewController? {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        } else if let tabBarSelected = (self as? UITabBarController)?.selectedViewController {
            return tabBarSelected.topMostViewController()
        } else if let navVisible = (self as? UINavigationController)?.visibleViewController {
            return navVisible.topMostViewController()
        } else {
            return self
        }
    }
}
