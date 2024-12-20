//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class CoreNavigationController: UINavigationController {
    public var remoteLogger = RemoteLogger.shared
    public override var prefersStatusBarHidden: Bool {
        topViewController?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }
    public override var childForStatusBarStyle: UIViewController? {
        topViewController?.preferredStatusBarStyle != .default ? topViewController : nil
    }

    // MARK: - Initializers

    public init() {
        let emptyViewController = EmptyViewController(nibName: nil, bundle: nil)
        super.init(rootViewController: emptyViewController)
        view.backgroundColor = .backgroundLightest
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        view.backgroundColor = .backgroundLightest
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        view.backgroundColor = .backgroundLightest
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
    }

    // MARK: - Navigation Methods

    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // Pushing a navigation controller raises an exception
        // so we prevent that and send an error report to Crashlytics about it.
        if let navController = viewController as? UINavigationController {
            let navControllerName = String(describing: type(of: navController))
            let navStack = navController.viewControllers
                .map { $0.loggableName }
                .joined(separator: ", ")
            remoteLogger.logError(
                name: "Pushing nav controller from CoreNavigationController was prevented",
                reason: "\(navControllerName) [\(navStack)]"
            )
            return
        }

        super.pushViewController(viewController, animated: animated)
    }
}

extension CoreNavigationController: UIGestureRecognizerDelegate {

    /**
     We only want the pop navigation gesture to work when there are multiple view controllers in the stack.
     Enabling it on the root view when it also have a swipe gesture setup causes a weird screen freeze issue.
     */
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count != 1
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
