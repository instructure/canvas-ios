//
//  PushAnimatedTransitioning.swift
//  Teacher
//
//  Created by Ben Kraus on 5/23/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

public class PushAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)!
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        if toViewController.isBeingPresented {
            toView.transform = CGAffineTransform(translationX: fromView.frame.size.width, y: 0)
            containerView.addSubview(toView)
        } else {
            containerView.insertSubview(toView, belowSubview: fromView)
            toView.transform = CGAffineTransform(translationX: -fromView.frame.size.width/3, y: 0)
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            if toViewController.isBeingPresented {
                toView.transform = .identity
                fromView.transform = CGAffineTransform(translationX: -fromView.frame.size.width/3, y: 0)
            } else {
                fromView.transform = CGAffineTransform(translationX: fromView.frame.size.width, y: 0)
                toView.transform = .identity
            }
        }, completion: { (finished) in
            toView.transform = .identity
            fromView.transform = .identity
            transitionContext.completeTransition(finished)
        })
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.275
    }
}

public class PushTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushAnimatedTransitioning()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushAnimatedTransitioning()
    }
}
