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

/**
 The purpose of this view controller is to display the split view's primary viewcontroller in full screen mode. This is achieved by passing a placeholder primary view to the split viewcontroller while manually adding the real primary viewcontroller as an overlay on top of the split view. Setting the size of this overlay viewcontroller will achieve the full screen mode.
 */
public class FullScreenPrimaryHelmSplitViewController: HelmSplitViewController {
    /** Instead of the first viewcontroller we return the full screen capable overlay viewcontroller. */
    public override var masterNavigationController: UINavigationController? { fullscreenPrimaryController }

    private enum State {
        case fullScreen
        case divided
        case hidden
    }
    private weak var fullscreenPrimaryController: UINavigationController?
    // This view won't be visible because our primary overlay viewcontroller will fully cover it. We use this to set the width of the primary overlay controller when not in full screen mode.
    private weak var primaryPlaceHolder: UINavigationController?
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

    // MARK: - UISplitViewControllerDelegate

    public override func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        super.splitViewController(svc, willChangeTo: displayMode)
        state = (displayMode == .secondaryOnly ? .hidden : .divided)

        // When collapsing the primary overlay view the placeholder beneath it becomes visible during the animation's duration. Applying the same nav bar style makes it look better.
        if displayMode == .secondaryOnly {
            applyDetailNavBarStyleToPlaceholder()
        }
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count != 1 {
            state = .divided
        }
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count == 1 {
            state = .fullScreen
        }
    }
}
