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

open class SmallModalNavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .custom
        preferredContentSize = CGSize(width: 300, height: 240)
        transitioningDelegate = self
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        preferredContentSize = rootViewController.preferredContentSize
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        modalPresentationStyle = .custom
        preferredContentSize = CGSize(width: 300, height: 240)
        transitioningDelegate = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
    }
    
    let txDelegate = FadeInOutTransition()
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return txDelegate
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return txDelegate
    }
}


class FadeInOutTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let duration = 0.2
    
    let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return view
    }()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func transitionToModal(_ modal: SmallModalNavigationController, inContext context: UIViewControllerContextTransitioning) {
        let view = modal.view
        let containerView = context.containerView
        let containerBounds = containerView.bounds
        
        shadowView.frame = containerView.bounds
        containerView.addSubview(shadowView)
        containerView.addSubview(view!)
        
        shadowView.alpha = 0.0
        view?.alpha = 0.0
        let finalTX = view?.transform
        view?.transform = (finalTX?.scaledBy(x: 1.2, y: 1.2))!
        view?.center = CGPoint(x: containerBounds.midX, y: containerBounds.size.height/3.0 + containerBounds.origin.y)
        view?.bounds = CGRect(origin: CGPoint.zero, size: modal.preferredContentSize)
        view?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            
            self.shadowView.alpha = 1
            view?.alpha = 1
            view?.transform = finalTX!
        
        }) { finished in
            context.completeTransition(true)
        }
    }
    
    func transitionFromModel(_ modal: SmallModalNavigationController, inContext context: UIViewControllerContextTransitioning) {
        let view = modal.view
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            self.shadowView.alpha = 0.0
            view?.alpha = 0.0
            view?.transform = (view?.transform.scaledBy(x: 0.9, y: 0.9))!
        }) { finished in
            self.shadowView.removeFromSuperview()
            view?.removeFromSuperview()
            context.completeTransition(true)
        }
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        if let destination = context.viewController(forKey: UITransitionContextViewControllerKey.to) as? SmallModalNavigationController {
            transitionToModal(destination, inContext: context)
        } else if let source = context.viewController(forKey: UITransitionContextViewControllerKey.from) as? SmallModalNavigationController {
            transitionFromModel(source, inContext: context)
        }
    }
}
