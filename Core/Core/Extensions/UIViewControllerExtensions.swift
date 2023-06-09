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

    public var isInSplitViewDetail: Bool {
        if
            let splitView = splitViewController,
            splitView.viewControllers.count == 2,
            let nav = splitView.viewControllers.last as? UINavigationController,
            nav.viewControllers.contains(self) || (parent != nil && nav.viewControllers.contains(parent!)) {
            return true
        }
        return false
    }

    public var splitDisplayModeButtonItem: UIBarButtonItem? {
        guard let splitView = splitViewController else { return nil }
        let defaultButton = splitView.displayModeButtonItem
        let isExpanded = splitView.displayMode == .oneOverSecondary || splitView.displayMode == .secondaryOnly
        let icon: UIImage = isExpanded ? .exitFullScreenLine : .fullScreenLine
        let buttonItem = UIBarButtonItem(image: icon, style: .plain, target: defaultButton.target, action: defaultButton.action)
        buttonItem.accessibilityLabel = splitView.isCollapsed ? NSLocalizedString("Collapse", bundle: .core, comment: "") : NSLocalizedString("Expand", bundle: .core, comment: "")
        return buttonItem
    }

    public func findParentViewController<T: UIViewController>() -> T? {
        if let self = self as? T {
            return self
        } else if let parent {
            return parent.findParentViewController()
        } else {
            return nil
        }
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
        button.accessibilityIdentifier = "screen.dismiss"
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

    public func unembed() {
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
        didMove(toParent: nil)
    }

    public func embed(_ child: UIViewController, in container: UIView, constraintHandler: ((UIViewController, UIView) -> Void)? = nil) {
        addChild(child)
        container.addSubview(child.view)
        if let constraintHandler = constraintHandler {
            constraintHandler(child, container)
        } else {
            child.view.pin(inside: container)
        }
        child.didMove(toParent: self)
    }

    public func syncNavigationBar(with viewController: UIViewController) -> [NSKeyValueObservation] {
        title = viewController.title
        navigationItem.title = viewController.title
        navigationItem.titleView = viewController.navigationItem.titleView
        let right = navigationItem.rightBarButtonItems ?? []
        let left = navigationItem.leftBarButtonItems ?? []
        let leftItemsSupplementBackButton = navigationItem.leftItemsSupplementBackButton
        navigationItem.rightBarButtonItems = (right + (viewController.navigationItem.rightBarButtonItems ?? [])).removeDuplicates()
        navigationItem.leftBarButtonItems = (viewController.navigationItem.leftBarButtonItems ?? []) + left
        navigationItem.leftItemsSupplementBackButton = viewController.navigationItem.leftItemsSupplementBackButton || leftItemsSupplementBackButton

        var observations = [
            viewController.observe(\.title) { [weak self] item, _ in
                self?.title = item.title
            },
            viewController.navigationItem.observe(\.title) { [weak self] item, _ in
                self?.navigationItem.title = item.title
            },
            viewController.navigationItem.observe(\.titleView) { [weak self] item, _ in
                self?.navigationItem.titleView = item.titleView
            },
            viewController.navigationItem.observe(\.rightBarButtonItems) { [weak self] item, _ in
                self?.navigationItem.rightBarButtonItems = (item.rightBarButtonItems ?? []) + right
            },
            viewController.navigationItem.observe(\.leftBarButtonItems) { [weak self] item, _ in
                self?.navigationItem.leftBarButtonItems = (item.leftBarButtonItems ?? []) + left
            },
            viewController.navigationItem.observe(\.leftItemsSupplementBackButton) { [weak self] item, _ in
                self?.navigationItem.leftItemsSupplementBackButton = item.leftItemsSupplementBackButton || leftItemsSupplementBackButton
            },
        ]

        if #available(iOSApplicationExtension 16.0, *) {
            observations.append(viewController.navigationItem.observe(\.trailingItemGroups) { [weak self] item, _ in
                let groupButtons = item.trailingItemGroups.flatMap { itemGroup in
                    itemGroup.barButtonItems
                }
                self?.navigationItem.rightBarButtonItems = groupButtons + right
            })
        }

        return observations
    }

    public func showPermissionError(_ error: PermissionError) {
        let alert = UIAlertController(title: NSLocalizedString("Permission Needed", comment: ""), message: error.message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Settings", comment: ""), style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            AppEnvironment.shared.loginDelegate?.openExternalURL(url)
        })
        alert.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel))
        AppEnvironment.shared.router.show(alert, from: self, options: .modal())
    }

    public func showThemeSelectorAlert() {

        // Don't show the theme selector popup for UI Tests
        guard !ProcessInfo.isUITest else { return }

        let alert = UIAlertController(title: NSLocalizedString("Canvas is now available in dark theme", bundle: .core, comment: ""),
                                      message: NSLocalizedString("Choose your app appearance!\nYou can change it later in the settings menu.", bundle: .core, comment: ""),
                                      preferredStyle: .alert)

        alert.addAction(AlertAction(NSLocalizedString("System settings", bundle: .core, comment: ""), style: .default) {_ in self.setStyle(style: .unspecified)})
        alert.addAction(AlertAction(NSLocalizedString("Light theme", bundle: .core, comment: ""), style: .default) {_ in self.setStyle(style: .light)})
        alert.addAction(AlertAction(NSLocalizedString("Dark theme", bundle: .core, comment: ""), style: .default) {_ in self.setStyle(style: .dark)})
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel) {_ in self.setStyle(style: .light)})
        AppEnvironment.shared.router.show(alert, from: self, options: .modal())
    }

    private func setStyle(style: UIUserInterfaceStyle?) {
        let env = AppEnvironment.shared
        env.userDefaults?.interfaceStyle = style
        if let window = env.window {
            window.updateInterfaceStyle(style)
        }
    }

    public enum PermissionError {
        case camera, microphone, notifications

        var message: String {
            switch self {
            case .camera:
                return NSLocalizedString("You must enable Camera permissions in Settings.", comment: "")
            case .microphone:
                return NSLocalizedString("You must enable Microphone permissions in Settings.", comment: "")
            case .notifications:
                return NSLocalizedString("You must allow notifications in Settings to set reminders.", comment: "")
            }
        }
    }
}

public class ResetTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public static let shared = ResetTransitionDelegate()
}
