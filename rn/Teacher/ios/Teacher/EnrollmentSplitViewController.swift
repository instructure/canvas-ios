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
import CanvasCore

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
