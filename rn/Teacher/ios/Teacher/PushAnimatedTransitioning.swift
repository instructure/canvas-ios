//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
