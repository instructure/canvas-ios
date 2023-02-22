//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

let drawerWidth: CGFloat = 300.0
let animationDuration = 0.275

public class SideMenuOpenTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from)?.view,
            let to = transitionContext.viewController(forKey: .to)?.view
            else {
                return transitionContext.completeTransition(false)
        }

        transitionContext.containerView.insertSubview(to, belowSubview: from)

        let isRTL = UIView.userInterfaceLayoutDirection(for: from.semanticContentAttribute) == .rightToLeft

        var fromFrame = from.frame
        var toFrame = to.frame
        toFrame.size.width = drawerWidth
        toFrame.origin.x = isRTL ? fromFrame.width : -drawerWidth
        to.frame = toFrame

        fromFrame.origin.x += isRTL ? -drawerWidth : drawerWidth
        toFrame.origin.x = isRTL ? (fromFrame.width - drawerWidth) : 0
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            from.frame = fromFrame
            to.frame = toFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
}

class SideMenuCloseTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from)?.view,
            let to = transitionContext.viewController(forKey: .to)?.view
            else {
                return transitionContext.completeTransition(false)
        }

        let isRTL = UIView.userInterfaceLayoutDirection(for: from.semanticContentAttribute) == .rightToLeft

        var fromFrame = from.frame
        var toFrame = to.frame

        fromFrame.origin.x = isRTL ? toFrame.width : -fromFrame.width
        toFrame.origin.x = 0
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            from.frame = fromFrame
            to.frame = toFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
}

public class SideMenuPresentationController: UIPresentationController {
    let dimmer = UIButton()

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else { return }

        let backGroundColor: UIColor = traitCollection.isDarkInterface ? .backgroundLightest : .backgroundDarkest
        dimmer.backgroundColor = backGroundColor.withAlphaComponent(0.9)
        dimmer.alpha = 0
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dimmer)
        NSLayoutConstraint.activate([
            dimmer.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        ])
        dimmer.addTarget(self, action: #selector(tapped), for: .primaryActionTriggered)
        dimmer.accessibilityLabel = NSLocalizedString("Close", bundle: .core, comment: "")
        dimmer.accessibilityFrame = CGRect(x: drawerWidth, y: 0, width: containerView.bounds.width - drawerWidth, height: containerView.bounds.height)

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmer.alpha = 1
        })
    }

    public override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if !completed {
            dimmer.removeFromSuperview()
        }
    }

    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmer.alpha = 0
        })
    }

    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            dimmer.removeFromSuperview()
        }
    }

    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        let isRTL = UIView.userInterfaceLayoutDirection(for: container.semanticContentAttribute) == .rightToLeft
        var frame = container.frame
        frame.size.width = drawerWidth
        if isRTL {
            frame.origin.x = container.frame.width - drawerWidth
        }
        return frame
    }

    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let backGroundColor: UIColor = traitCollection.isDarkInterface ? .backgroundLightest : .backgroundDarkest
        dimmer.backgroundColor = backGroundColor.withAlphaComponent(0.9)
    }

    @objc func tapped(gesture: UITapGestureRecognizer) {
        self.presentingViewController.dismiss(animated: true)
    }
}

public class SideMenuTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public static let shared = SideMenuTransitioningDelegate()

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideMenuOpenTransitioning()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideMenuCloseTransitioning()
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SideMenuPresentationController(presentedViewController: presented, presenting: presenting)
    }

    public static func applyTransitionSettings(on viewController: UIViewController) {
        viewController.modalPresentationStyle = .custom
        viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.transitioningDelegate = SideMenuTransitioningDelegate.shared
    }
}
