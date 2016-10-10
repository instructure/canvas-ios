//
//  SmallModalNavigationController.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 7/23/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

public class SmallModalNavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .Custom
        preferredContentSize = CGSize(width: 300, height: 240)
        transitioningDelegate = self
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        preferredContentSize = rootViewController.preferredContentSize
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        modalPresentationStyle = .Custom
        preferredContentSize = CGSize(width: 300, height: 240)
        transitioningDelegate = self
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
    }
    
    let txDelegate = FadeInOutTransition()
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return txDelegate
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return txDelegate
    }
}


class FadeInOutTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.2
    
    let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return view
    }()

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func transitionToModal(modal: SmallModalNavigationController, inContext context: UIViewControllerContextTransitioning) {
        let view = modal.view
        let containerView = context.containerView()
        let containerBounds = containerView.bounds
        
        shadowView.frame = containerView.bounds
        containerView.addSubview(shadowView)
        containerView.addSubview(view)
        
        shadowView.alpha = 0.0
        view.alpha = 0.0
        let finalTX = view.transform
        view.transform = CGAffineTransformScale(finalTX, 1.2, 1.2)
        view.center = CGPoint(x: CGRectGetMidX(containerBounds), y: containerBounds.size.height/3.0 + containerBounds.origin.y)
        view.bounds = CGRect(origin: CGPointZero, size: modal.preferredContentSize)
        view.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: {
            
            self.shadowView.alpha = 1
            view.alpha = 1
            view.transform = finalTX
        
        }) { finished in
            context.completeTransition(true)
        }
    }
    
    func transitionFromModel(modal: SmallModalNavigationController, inContext context: UIViewControllerContextTransitioning) {
        let view = modal.view
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseIn, animations: {
            self.shadowView.alpha = 0.0
            view.alpha = 0.0
            view.transform = CGAffineTransformScale(view.transform, 0.9, 0.9)
        }) { finished in
            self.shadowView.removeFromSuperview()
            view.removeFromSuperview()
            context.completeTransition(true)
        }
    }
    
    func animateTransition(context: UIViewControllerContextTransitioning) {
        if let destination = context.viewControllerForKey(UITransitionContextToViewControllerKey) as? SmallModalNavigationController {
            transitionToModal(destination, inContext: context)
        } else if let source = context.viewControllerForKey(UITransitionContextFromViewControllerKey) as? SmallModalNavigationController {
            transitionFromModel(source, inContext: context)
        }
    }
}
