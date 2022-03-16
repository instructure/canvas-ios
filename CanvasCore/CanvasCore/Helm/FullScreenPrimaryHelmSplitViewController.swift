//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import Core

/**
 The purpose of this view controller is to display the split view's primary viewcontroller in full screen mode. This is achieved by passing a placeholder primary view to the split viewcontroller while manually adding the real primary viewcontroller as an overlay on top of the split view. Setting the size of this overlay viewcontroller will achieve the full screen mode.

 Do not use the `viewControllers` array directly. Use `masterNavigationController` and `detailNavigationController`helper properties instead.
 */
public class FullScreenPrimaryHelmSplitViewController: HelmSplitViewController {
    /** Instead of the first viewcontroller (which is just a placeholder) we return the full screen capable overlay viewcontroller. */
    public override var masterNavigationController: UINavigationController? { fullscreenPrimaryController }

    private enum State {
        case fullScreen
        case divided
        case hidden
    }
    private weak var fullscreenPrimaryController: UINavigationController?
    // This view won't be visible because our primary overlay viewcontroller will fully cover it. We use this to set the width of the primary overlay controller when not in full screen mode.
    private weak var primaryPlaceHolder: UINavigationController?
    private var primaryNavItemChangeObserver: NSKeyValueObservation?
    private var state: State = .fullScreen {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
                self?.updateFrame()
                self?.view.layoutIfNeeded()
            }
        }
    }

    public init(primary: UINavigationController, secondary: UINavigationController) {
        super.init(nibName: nil, bundle: nil)

        let primaryPlaceHolder = HelmNavigationController()
        self.primaryPlaceHolder = primaryPlaceHolder
        viewControllers = [primaryPlaceHolder, secondary]
        embed(primary, in: view) { _, _ in }
        fullscreenPrimaryController = primary
    }


    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if primaryNavItemChangeObserver == nil {
            subscribeMenuButtonDisappearanceWorkaround()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFrame()
    }

    /**
     UISplitViewController still uses auto resizing masks instead of auto layout constraints, so we can't use constraints and have to manually update view frames.
     */
    private func updateFrame() {
        guard let overlayView = fullscreenPrimaryController?.view else { return }

        switch state {
            case .fullScreen: // copy size of the parent split view controller
                overlayView.frame = view.frame
            case .divided: // copy primary view's size
                var frame = primaryPlaceHolder?.view.frame ?? .zero
                frame.origin.x = 0
                overlayView.frame = frame
            case .hidden: // push view out of screen to the left
                var frame = overlayView.frame
                frame.origin.x = -frame.width
                overlayView.frame = frame
        }
    }

    private func applyDetailNavBarStyleToPlaceholder() {
        guard
            let placeholderNavBar = primaryPlaceHolder?.navigationBar,
            let detailNavBar = detailNavigationController?.navigationBar
        else {
            return
        }

        placeholderNavBar.barTintColor = detailNavBar.barTintColor
        placeholderNavBar.tintColor = detailNavBar.tintColor
        placeholderNavBar.shadowImage = detailNavBar.shadowImage
        placeholderNavBar.isTranslucent = detailNavBar.isTranslucent
        placeholderNavBar.barStyle = detailNavBar.barStyle
        placeholderNavBar.titleTextAttributes = detailNavBar.titleTextAttributes
    }

    /**
     Rotating of phones with notch removes the menu button in the nav bar. This method subscribes to navigationItem changes and re-adds the menu item in case it would get removed. When updating to iOS 14 check if this is still needed when using `.toolBar()` instead of `.navigationBarItems()` SwiftUI modifiers in `K5DashboardView`.
     */
    @available(iOS, obsoleted: 14)
    private func subscribeMenuButtonDisappearanceWorkaround() {
        primaryNavItemChangeObserver = fullscreenPrimaryController?.children.first?.navigationItem.observe(\.leftBarButtonItems, options: [.old, .new]) { navigationItem, change in
            guard
                let wrappedOldValue = change.oldValue,
                let oldValue = wrappedOldValue,
                let wrappedNewValue = change.newValue,
                let newValue = wrappedNewValue,
                !oldValue.isEmpty, newValue.isEmpty
            else {
                return
            }

            navigationItem.leftBarButtonItems = oldValue
        }
    }

    // MARK: - UISplitViewControllerDelegate

    public override func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        super.splitViewController(svc, willChangeTo: displayMode)
        state = {
            if displayMode == .secondaryOnly {
                return .hidden
            }

            guard let primaryNav = fullscreenPrimaryController else { return .divided }

            if primaryNav.viewControllers.count == 1 {
                return .fullScreen
            } else {
                return .divided
            }
        }()

        // When collapsing the primary overlay view the placeholder beneath it becomes visible during the animation's duration. Applying the same nav bar style makes it look better.
        if displayMode == .secondaryOnly {
            applyDetailNavBarStyleToPlaceholder()
        }
    }

    public override func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        super.splitViewController(splitViewController, separateSecondaryFrom: masterNavigationController ?? UIViewController())
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count != 1 {
            // Exception for the full screen K5SubjectView
            if navigationController.viewControllers.contains(where: { $0 is CoreHostingController<K5SubjectView> }) {
                state = .fullScreen
                return
            }
            state = .divided
        } else if navigationController.viewControllers.count == 1 { // if the nav controller pops to root then willShow won't trigger the fullscreen mode
            state = .fullScreen
        }
    }

    override public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count == 1 {
            state = .fullScreen
        }
    }
}
