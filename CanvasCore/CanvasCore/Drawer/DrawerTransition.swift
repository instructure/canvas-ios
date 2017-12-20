//
//  DrawerTransition.swift
//  CanvasCore
//
//  Created by Layne Moseley on 12/7/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

let DrawerWidth: CGFloat = 300.0
let AnimationDuration = 0.275
let DimmerTag = 12345

public class DrawerOpenTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func installDimmer(view: UIView) -> UIView? {
        let dimmer = UIView()
        dimmer.backgroundColor = UIColor(red:0.18, green:0.23, blue:0.27, alpha:0.9)
        dimmer.alpha = 0.0
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        dimmer.tag = DimmerTag
        view.addSubview(dimmer)
        NSLayoutConstraint.activate([
            dimmer.widthAnchor.constraint(equalTo: view.widthAnchor),
            dimmer.heightAnchor.constraint(equalTo: view.heightAnchor),
            dimmer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dimmer.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return dimmer
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
                let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let dimmer = installDimmer(view: fromVC.view)
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        var frame = toVC.view.frame
        frame.size.width = DrawerWidth
        frame.origin.x = -DrawerWidth
        toVC.view.frame = frame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            var frame = toVC.view.frame
            frame.origin.x = 0
            toVC.view.frame = frame
            fromVC.view.center.x += DrawerWidth
            dimmer?.alpha = 1.0
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationDuration
    }
}

class DrawerCloseTransitioning : NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        let dimmer = toVC.view.viewWithTag(DimmerTag)
        var fromFrame = fromVC.view.frame
        fromFrame.origin.x = -fromFrame.width
        var toFrame = toVC.view.frame
        toFrame.origin.x = 0.0
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromVC.view.frame = fromFrame
                toVC.view.frame = toFrame
                dimmer?.alpha = 0.0
        },
            completion: { _ in
                let completed = !transitionContext.transitionWasCancelled
                if (completed) {
                    dimmer?.removeFromSuperview()
                }
                transitionContext.completeTransition(completed)
        })
    }
}

public class DrawerPresentationController: UIPresentationController {
    
    var installedGestures = false
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        var frame = container.frame
        frame.size.width = DrawerWidth
        return frame
    }
    
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let container = containerView else { return }
        if installedGestures == false {
            installedGestures = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
            container.addGestureRecognizer(tap)
        }
        var frame = container.frame
        frame.size.width = DrawerWidth
        presentedViewController.view.frame = frame
    }
    
    func tapped(gesture: UITapGestureRecognizer) {
        guard let container = containerView else { return }
        let location = gesture.location(in: container)
        if !presentedViewController.view.frame.contains(location) {
            self.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}

public class DrawerTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerOpenTransitioning()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerCloseTransitioning()
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DrawerPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
