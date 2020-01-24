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

import UIKit
let animationDuration = 0.275
let actionSheetHeight: CGFloat = 338.0

class ActionSheetController: UIViewController {
    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
        self.title = title
        modalPresentationStyle = .custom
        transitioningDelegate = ActionSheetTransitioningDelegate.shared
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        embed(viewController, in: container)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = viewController.navigationItem.title
        titleLabel.textColor = .named(.textDark)
        titleLabel.font = .scaledNamedFont(.semibold14)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

public class ActionSheetOpenTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from)?.view,
            let to = transitionContext.viewController(forKey: .to)?.view
            else {
                return transitionContext.completeTransition(false)
        }

        transitionContext.containerView.insertSubview(to, belowSubview: from)

        let fromFrame = from.frame
        var toFrame = to.frame
        toFrame.size.height = fromFrame.height / 2
        toFrame.origin.y = fromFrame.height
        to.frame = toFrame

        toFrame.origin.y = fromFrame.height - actionSheetHeight
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            to.frame = toFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
}

class ActionSheetCloseTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from)?.view,
            let to = transitionContext.viewController(forKey: .to)?.view
            else {
                return transitionContext.completeTransition(false)
        }

        let toFrame = to.frame
        var fromFrame = from.frame
        fromFrame.origin.y = toFrame.height

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            from.frame = fromFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
}

public class ActionSheetPresentationController: UIPresentationController {
    let dimmer = UIButton()

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else { return }

        dimmer.backgroundColor = UIColor.named(.backgroundDarkest).withAlphaComponent(0.9)
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
        dimmer.accessibilityFrame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height - actionSheetHeight)

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
        var frame = container.frame
        frame.size.height = frame.height / 2
        frame.origin.y = frame.height
        return frame
    }

    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }

    @objc func tapped(gesture: UITapGestureRecognizer) {
        self.presentingViewController.dismiss(animated: true)
    }
}

public class ActionSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public static let shared = ActionSheetTransitioningDelegate()

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ActionSheetOpenTransitioning()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ActionSheetCloseTransitioning()
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ActionSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
