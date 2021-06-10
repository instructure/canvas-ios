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

    private weak var fullscreenPrimaryController: UINavigationController?
    private var fullscreenWidthConstraint: NSLayoutConstraint?
    private var splitModeConstraint: NSLayoutConstraint?

    public init(primary: UINavigationController, secondary: UINavigationController) {
        super.init(nibName: nil, bundle: nil)

        // This view won't be visible because our primary overlay viewcontroller will fully cover it. We use this to set the width of the primary overlay controller when not in full screen mode.
        let primaryPlaceHolder = UIViewController()
        viewControllers = [primaryPlaceHolder, secondary]
        embed(primary, in: view) { [weak self] childViewController, containerView in
            let childView = childViewController.view!
            childView.translatesAutoresizingMaskIntoConstraints = false
            childView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
            childView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
            containerView.bottomAnchor.constraint(equalTo: childView.bottomAnchor, constant: 0).isActive = true
            self?.fullscreenWidthConstraint = containerView.trailingAnchor.constraint(equalTo: childView.trailingAnchor, constant: 0)
            self?.fullscreenWidthConstraint?.isActive = true
        }
        splitModeConstraint = primary.view.trailingAnchor.constraint(equalTo: primaryPlaceHolder.view.trailingAnchor)
        fullscreenPrimaryController = primary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func togglePrimaryFullscreen(to isFullscreen: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.splitModeConstraint?.isActive = !isFullscreen
            self?.fullscreenWidthConstraint?.isActive = isFullscreen
            self?.view.layoutIfNeeded()
        }
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count != 1 {
            togglePrimaryFullscreen(to: false)
        }
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count == 1 {
            togglePrimaryFullscreen(to: true)
        }
    }
}
