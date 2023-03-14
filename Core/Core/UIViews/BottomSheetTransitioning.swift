//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import UIKit

class BottomSheetOpenTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from)?.view,
            let to = transitionContext.viewController(forKey: .to)?.view
        else {
            return transitionContext.completeTransition(false)
        }

        transitionContext.containerView.insertSubview(to, belowSubview: from)
        to.frame.origin.y = from.frame.height
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: {
            to.frame.origin.y -= to.frame.height
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return BottomSheetTransitioningDelegate.transitionDuration
    }
}

class BottomSheetCloseTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from)?.view,
            let to = transitionContext.viewController(forKey: .to)?.view
        else {
            return transitionContext.completeTransition(false)
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            from.frame.origin.y = to.frame.height
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return BottomSheetTransitioningDelegate.transitionDuration
    }
}

class BottomSheetPresentationController: UIPresentationController {
    let dimmer = UIButton()

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else { return }

        dimmer.alpha = 0
        dimmer.backgroundColor = .black.withAlphaComponent(0.2)
        containerView.addSubview(dimmer)
        dimmer.pin(inside: containerView)
        dimmer.addTarget(self, action: #selector(tapped), for: .primaryActionTriggered)
        dimmer.accessibilityLabel = NSLocalizedString("Close", bundle: .core, comment: "")
        dimmer.accessibilityFrame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height - presentedViewController.view.frame.height)

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmer.alpha = 1
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if !completed {
            dimmer.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmer.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            dimmer.removeFromSuperview()
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let view = containerView else { return .zero }
        let presented = presentedViewController.view.frame
        return CGRect(x: 0, y: view.frame.height - presented.height, width: presented.width, height: presented.height)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }

    @objc func tapped(gesture: UITapGestureRecognizer) {
        self.presentingViewController.dismiss(animated: true)
    }
}

public class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public static let shared = BottomSheetTransitioningDelegate()
    static let transitionDuration: TimeInterval = 0.275

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSheetOpenTransitioning()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSheetCloseTransitioning()
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
