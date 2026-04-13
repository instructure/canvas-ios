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

public class CoreSplitViewController: UISplitViewController {

    public convenience init() {
        self.init(style: .doubleColumn)
    }

    public override init(style: UISplitViewController.Style) {
        super.init(style: style)
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .displace
        displayModeButtonVisibility = .never
        delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        registerForTraitChanges()
    }

    public override var prefersStatusBarHidden: Bool {
        return masterNavigationController?.prefersStatusBarHidden ?? false
    }

    public override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        masterNavigationController?.syncStyles()

        if isCollapsed {
            masterNavigationController?.show(vc, sender: sender)
        } else {
            setViewController(vc, for: .secondary)
            show(.secondary)
        }
    }

    private func updateTitleViews() {
        // Recreating the titleView seems to be the most reliable way to get it to draw
        // correctly when the traitCollection changes on iPad
        if let titleView = masterTopViewController?.navigationItem.titleView as? TitleSubtitleView {
            masterTopViewController?.navigationItem.titleView = titleView.recreate()
        }
        if let titleView = detailTopViewController?.navigationItem.titleView as? TitleSubtitleView {
            detailTopViewController?.navigationItem.titleView = titleView.recreate()
        }
    }

    @available(iOS, deprecated: 26, message: "iOS26 has a default implementation")
    private func prettyDisplayModeButtonItem(_ displayMode: DisplayMode) -> UIBarButtonItem {
        let collapse = displayMode == .oneOverSecondary || displayMode == .secondaryOnly
        let icon: UIImage = collapse ? .exitFullScreenLine : .fullScreenLine
        let prettyButton = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(didTabDisplayButton))
        prettyButton.accessibilityLabel = collapse ?
            String(localized: "Collapse detail view", bundle: .core) :
            String(localized: "Expand detail view", bundle: .core)
        return prettyButton
    }

    @objc private func didTabDisplayButton() {
        if displayMode == .secondaryOnly {
            show(.primary)
        } else {
            hide(.primary)
        }
    }

    private func registerForTraitChanges() {
        let traits: [UITrait] = [UITraitVerticalSizeClass.self, UITraitHorizontalSizeClass.self, UITraitLayoutDirection.self]
        registerForTraitChanges(traits) { (self: CoreSplitViewController, _) in
            self.updateTitleViews()
        }
    }
}

extension CoreSplitViewController: UISplitViewControllerDelegate {

    public func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        guard let secondaryView = secondaryViewController else { return }
        resetSecondaryViewDisplayModeButton(secondaryView)
        (secondaryView as? UINavigationController)?.syncStyles()
        updateTitleViews()
    }

    public func splitViewController(_ svc: UISplitViewController, willShow column: UISplitViewController.Column) {
        if case .secondary = column {
            //resetSecondaryView()
        }
    }

    public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {

        guard let secondaryView = secondaryViewController else { return }

        resetSecondaryViewDisplayModeButton(secondaryView, displayMode: displayMode)

        if let top = (secondaryView as? UINavigationController)?.topViewController,
           (top is EmptyViewController) == false {
            NotificationCenter.default.post(name: NSNotification.Name.SplitViewControllerWillChangeDisplayModeNotification, object: self)
        }
    }

    /// This necessary to fix an issue on iPadOS 26, where app freezes upon window resizing.
    public func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        .primary
    }

    public func splitViewController(
        _ svc: UISplitViewController,
        displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode
    ) -> UISplitViewController.DisplayMode {

        switch proposedDisplayMode {
        case .oneOverSecondary:
            return .secondaryOnly
        default:
            return .oneBesideSecondary
        }
    }

    private func resetSecondaryView() {
        guard
            let primary = masterNavigationController,
            let secondary = detailNavigationController
        else { return }

        // Setup default detail view provided by the master view controller
        if primary.viewControllers.count > 1,
           let defaultViewProvider = primary.viewControllers.last as? DefaultViewProvider,
           let defaultRoute = defaultViewProvider.defaultViewRoute,
           let defaultViewController = AppEnvironment.shared.router.match(defaultRoute.url, userInfo: defaultRoute.userInfo) {

            secondary.viewControllers = [defaultViewController]
            secondary.syncStyles(from: primary, to: secondary)

            if let routeTemplate = AppEnvironment.shared.router.template(for: defaultRoute.url) {
                RemoteLogger.shared.logBreadcrumb(route: routeTemplate, viewController: defaultViewController)
            }
        }

        // Default behaviour of putting the current top viewcontroller into a nav controller and moving it to the detail view
        if primary.viewControllers.count >= 2 {

            let newDeets = primary.viewControllers[primary.viewControllers.count - 1]
            primary.popViewController(animated: true)

            if let nav = newDeets as? UINavigationController,
               let nvc = nav.viewControllers.first {
                secondary.viewControllers = [nvc]
            } else {
                secondary.viewControllers = [newDeets]
            }
        }
    }

    private func resetSecondaryViewDisplayModeButton(_ viewController: UIViewController, displayMode: UISplitViewController.DisplayMode? = nil) {

        let viewControllers = (viewController as? UINavigationController)?.viewControllers ?? [viewController]
        for vc in viewControllers where (vc is EmptyViewController) == false {
            vc.navigationItem.leftItemsSupplementBackButton = true
            vc.navigationItem.leftBarButtonItem = prettyDisplayModeButtonItem(displayMode ?? self.displayMode)
        }
    }
}

// - MARK: Master Navigation Controller Transition Actions

extension CoreSplitViewController: UINavigationControllerDelegate {

    /**
     This method gets called only when a real transition occurs. UINavigationControllerDelegate.willShow/didShow also
     gets called when the navigation controller is removed from the screen and re-added for example on a tab bar change
     event so we can't use those to determine when a view controller is pushed for the first time.
     */
    open func navigationController(_ navigationController: UINavigationController,
                                   animationControllerFor operation: UINavigationController.Operation,
                                   from fromVC: UIViewController,
                                   to toVC: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
        toVC.showDefaultDetailViewIfNeeded()
        return nil
    }
}

// Needed for the above bug mentioned in comments
extension CoreSplitViewController: UIGestureRecognizerDelegate { }

// - MARK: Helper Utils

private extension UISplitViewController {

    var secondaryViewController: UIViewController? {
        viewController(for: .secondary)
    }
}
