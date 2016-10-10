//
//  SimpleTransitionCoordinator.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent

class SimpleTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator, UIViewControllerTransitionCoordinatorContext {
    var animateAlongsideTransitionWasCalled = false

    func viewControllerForKey(key: String) -> UIViewController? {
        return nil
    }

    func viewForKey(key: String) -> UIView? {
        return nil
    }

    func containerView() -> UIView {
        return UIView()
    }

    func presentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.CurrentContext
    }

    func transitionDuration() -> NSTimeInterval {
        return 1
    }

    func completionCurve() -> UIViewAnimationCurve {
        return UIViewAnimationCurve.EaseIn
    }

    func completionVelocity() -> CGFloat {
        return 1.0
    }

    func percentComplete() -> CGFloat {
        return 100.0
    }

    func initiallyInteractive() -> Bool {
        return false
    }
    
    var isInterruptible: Bool {
        return true
    }

    func isAnimated() -> Bool {
        return false
    }

    func isCancelled() -> Bool {
        return false
    }

    func isInteractive() -> Bool {
        return false
    }

    func targetTransform() -> CGAffineTransform {
        return CGAffineTransformIdentity
    }

    func animateAlongsideTransition(animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animateAlongsideTransitionWasCalled = true
        animation?(self)
        completion?(self)
        return true
    }

    func animateAlongsideTransitionInView(view: UIView?, animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    func notifyWhenInteractionEndsUsingBlock(handler: (UIViewControllerTransitionCoordinatorContext) -> Void) {
        return
    }
    func notifyWhenInteractionChangesUsingBlock(handler: (UIViewControllerTransitionCoordinatorContext) -> Void) {
        return
    }
}
