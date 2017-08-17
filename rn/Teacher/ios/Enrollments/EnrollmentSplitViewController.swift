//
//  EnrollmentSplitViewController.swift
//  Teacher
//
//  Created by Ben Kraus on 8/10/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

class EnrollmentSplitViewController: HelmSplitViewController {
    
    override init() {
        super.init()
        
        viewControllers = [UINavigationController(rootViewController: UIViewController()), UINavigationController(rootViewController: UIViewController())]
        preferredDisplayMode = .allVisible
        definesPresentationContext = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var fakeController: UIViewController? {
        if let nav = viewControllers.first as? UINavigationController, let fake = nav.viewControllers.first as? EmptyViewController {
            return fake
        }
        return nil
    }
    
    func navigateToCoursePicker() {
        guard let vc = fakeController else { return }
        guard let tabBarController = vc.tabBarController else { return }
        guard let window = UIApplication.shared.delegate?.window else { return }
        
        let enrollments = RootTabBarController(branding: nil).coursesTab()
        var vcs = tabBarController.viewControllers ?? []
        vcs[0] = enrollments
        
        let snapshot = tabBarController.view.snapshotView(afterScreenUpdates: false) ?? UIView()
        let tabVCView = tabBarController.view ?? UIView()
        
        tabVCView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        window?.insertSubview(snapshot, aboveSubview: tabVCView)
        
        UIView.animate(withDuration: 0.3, animations: {
            vc.tabBarController?.setViewControllers(vcs, animated: false)
            snapshot.center = CGPoint(x: tabVCView.center.x + tabVCView.frame.size.width + 20 /* who knows why */, y: tabVCView.center.y)
            tabVCView.transform = CGAffineTransform.identity
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}

extension EnrollmentSplitViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == fakeController {
            navigateToCoursePicker()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC == fakeController {
            return NoPopAnimator()
        } else {
            return nil
        }
    }
}

class NoPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// Needed for the above bug mentioned in comments
extension EnrollmentSplitViewController: UIGestureRecognizerDelegate { }
