//
//  NoAnimatedTransitioning.swift
//  Teacher
//
//  Created by Ben Kraus on 7/5/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

public class NoAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)!
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let containerView = transitionContext.containerView
        
        if toViewController.isBeingPresented {
            containerView.addSubview(toView)
        } else {
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        transitionContext.completeTransition(true)
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.0
    }
}
