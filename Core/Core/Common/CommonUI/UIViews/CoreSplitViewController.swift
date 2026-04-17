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

    private lazy var expandButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: .fullScreenLine,
            style: .plain, target: self, action: #selector(didTapExpand)
        )
        return button
    }()

    public override var prefersStatusBarHidden: Bool {
        return masterNavigationController?.topViewController?.prefersStatusBarHidden ?? false
    }

    public override var childForStatusBarStyle: UIViewController? {
        let topViewController = masterNavigationController?.topViewController
        if #available(iOS 26, *) {
            return topViewController
        } else {
            return topViewController?.preferredStatusBarStyle != .default ? topViewController : nil
        }
    }

    private func removeExpandButton() {
        guard let currentExpandableViewController else { return }

        var items = currentExpandableViewController.navigationItem.leftBarButtonItems ?? []
        items.removeAll(where: { $0 === expandButton })
        currentExpandableViewController.navigationItem.leftBarButtonItems = items
    }

    private weak var _currentExpandableViewController: UIViewController?
    fileprivate var currentExpandableViewController: UIViewController? {
        get { _currentExpandableViewController }
        set {
            removeExpandButton()

            if newValue is EmptyViewController { return }
            _currentExpandableViewController = newValue

            guard let viewController = newValue, isCollapsed == false
            else { return }

            var items = viewController.navigationItem.leftBarButtonItems ?? []
            if items.contains(expandButton) == false {
                items.insert(expandButton, at: 0)
            }

            viewController.navigationItem.leftBarButtonItems = items
            viewController.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    func updateExpandButtonState(for displayMode: UISplitViewController.DisplayMode?) {
        let mode = displayMode ?? self.displayMode
        let isExpanded = mode == .oneOverSecondary || mode == .secondaryOnly

        expandButton.image = isExpanded ? .exitFullScreenLine : .fullScreenLine
        expandButton.accessibilityLabel = isExpanded
            ? String(localized: "Collapse detail view", bundle: .core)
            : String(localized: "Expand detail view", bundle: .core)
    }

    @objc private func didTapExpand() {
        updateExpandButtonState(for: displayMode)

        let isExpanded = displayMode == .oneOverSecondary || displayMode == .secondaryOnly

        if isExpanded {
            show(.primary)
        } else {
            hide(.primary)
        }
    }

    private func updateTitleViews() {
        // Recreating the titleView seems to be the most reliable way to get it to draw
        // correctly when the traitCollection changes on iPad
        if let primaryViewController = masterNavigationController?.topViewController,
           let titleView = primaryViewController.navigationItem.titleView as? TitleSubtitleView {
            primaryViewController.navigationItem.titleView = titleView.recreate()
        }

        if let secondaryViewController = detailNavigationController?.topViewController,
           let titleView = secondaryViewController.navigationItem.titleView as? TitleSubtitleView {
            secondaryViewController.navigationItem.titleView = titleView.recreate()
        }
    }

    convenience init() {
        self.init(style: .doubleColumn)
        displayModeButtonVisibility = .never
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .displace
        delegate = self
    }

    public override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        detailNavigationController?.setViewControllers([vc], animated: false)
        show(.secondary)
    }
}

extension CoreSplitViewController: UISplitViewControllerDelegate {

    public func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        currentExpandableViewController = detailNavigationController?.topViewController
        masterNavigationController?.syncStyles()
    }

    public func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        currentExpandableViewController = nil
    }

    public func splitViewController(
        _ svc: UISplitViewController,
        didShow column: UISplitViewController.Column
    ) {
        masterNavigationController?.delegate = self
        detailNavigationController?.delegate = self
        currentExpandableViewController = detailNavigationController?.topViewController
        masterNavigationController?.syncStyles()
    }

    public func splitViewController(
        _ svc: UISplitViewController,
        willChangeTo displayMode: UISplitViewController.DisplayMode
    ) {
        masterNavigationController?.delegate = self
        detailNavigationController?.delegate = self
        currentExpandableViewController = detailNavigationController?.topViewController
        updateExpandButtonState(for: displayMode)

        if #unavailable(iOS 26) {
            updateTitleViews()
        }
    }

    public func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        currentExpandableViewController = nil

        if detailNavigationController?.topViewController == nil { return .primary }

        if let currentDetailVC = detailNavigationController?.topViewController,
           (currentDetailVC is EmptyViewController) {
            return if #available(iOS 26, *) { .compact } else { .primary }
        }

        return proposedTopColumn
    }
}

extension CoreSplitViewController: UINavigationControllerDelegate {

    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        if navigationController === detailNavigationController {
            currentExpandableViewController = viewController
        }

        // Show default when primary is popped
        guard isCollapsed == false,
              navigationController === masterNavigationController,
              let primaryView = navigationController.topViewController as? DefaultViewProvider,
              navigationController.transitionCoordinator?.viewController(forKey: .from) != nil
        else { return }

        primaryView.showDefaultDetailViewIfNeeded()
    }
}
