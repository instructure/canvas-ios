//
//  QuizIntroFooterView.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 11/18/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import Cartography
import SoPretty

class QuizIntroFooterView: UIView {
    let pageControl = UIPageControl()
    let takeButton = UIButton()
    private let takeabilityActivityIndicator = UIActivityIndicatorView()
    
    private var pageControlConstraintGroup = ConstraintGroup()
    private var takeButtonConstraintGroup = ConstraintGroup()

    private let visualEffectContainer = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        opaque = false
        backgroundColor = UIColor.clearColor()
        
        prepareBackgroundView()
        preparePageControl()
        prepareTakeButton()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: Layout

extension QuizIntroFooterView {
    func setTakeButtonOnscreen(onscreen: Bool, animated: Bool) {
        if onscreen {
            constrain(pageControl, visualEffectContainer.contentView, replace: pageControlConstraintGroup) { pageControl, contentView in
                pageControl.centerY == contentView.bottom + 60
            }
            constrain(takeButton, visualEffectContainer.contentView, replace: takeButtonConstraintGroup) { takeButton, contentView in
                takeButton.centerY == contentView.centerY
            }
        } else {
            constrain(pageControl, visualEffectContainer.contentView, replace: pageControlConstraintGroup) { pageControl, contentView in
                pageControl.centerY == contentView.centerY
            }
            constrain(takeButton, visualEffectContainer.contentView, replace: takeButtonConstraintGroup) { takeButton, contentView in
                takeButton.centerY == contentView.bottom + 60
            }
        }
        
        if animated {
            UIView.animateWithDuration(0.2, animations: visualEffectContainer.layoutIfNeeded)
        } else {
            visualEffectContainer.layoutIfNeeded()
        }
    }
}


// MARK: BackgroundView

extension QuizIntroFooterView {
    func prepareBackgroundView() {
        addSubview(visualEffectContainer)
        constrain(self, visualEffectContainer) { my, visualEffects in
            visualEffects.center == my.center
            visualEffects.size == my.size
        }
        
        
        let line = HairlineView()
        
        visualEffectContainer.contentView.addSubview(line)
        
        constrain(line, visualEffectContainer) { line, container in
            line.top == container.top
            line.left == container.left
            line.right == container.right
            line.height == 1.0
        }
    }
}


// MARK: Take Button

extension QuizIntroFooterView {
    func takeabilityUpdated(takeability: Takeability) {
        // get the last page, set it to show the big blue button
        switch takeability {
        case .NotTakeable(let reason):
            if reason == .Undecided {
                takeButton.setImage(nil, forState: .Normal)
                takeButton.setTitle("", forState: .Normal)
                
                takeabilityActivityIndicator.hidden = false
                takeabilityActivityIndicator.startAnimating()
            } else {
                let lockImage = UIImage(named: "lock", inBundle: NSBundle(forClass: QuizIntroViewController.self), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
                takeButton.imageView?.tintColor = UIColor.whiteColor()
                takeButton.setImage(lockImage, forState: .Normal)
                takeButton.setTitle(nil, forState: .Normal)
                
                takeabilityActivityIndicator.stopAnimating()
                takeabilityActivityIndicator.hidden = true
            }
            
        default:
            takeButton.setImage(nil, forState: .Normal)
            takeButton.setTitle(takeability.label, forState: .Normal)
            
            takeabilityActivityIndicator.stopAnimating()
            takeabilityActivityIndicator.hidden = true
        }
    }
    
    private func prepareTakeButton() {
        takeButton.backgroundColor = Brand.current().tintColor
        takeButton.layer.cornerRadius = 5.0
        takeButton.enabled = false
        
        visualEffectContainer.contentView.addSubview(takeButton)
        
        constrain(takeButton, visualEffectContainer.contentView) { takeButton, container in
            takeButton.leading  == container.leading + 20
            takeButton.trailing == container.trailing - 20
            takeButton.height   == 44.0
        }
        
        takeabilityActivityIndicator.hidden = true
        takeButton.addSubview(takeabilityActivityIndicator)
        constrain(takeabilityActivityIndicator, takeButton) { takeabilityActivityIndicator, takeButton in
            takeabilityActivityIndicator.center == takeButton.center
        }
        
        // start off screen
        setTakeButtonOnscreen(true, animated: false)
    }
}


// MARK: Page Control

extension QuizIntroFooterView {
    private func preparePageControl() {
        pageControl.pageIndicatorTintColor = Brand.current().tintColor
        pageControl.currentPageIndicatorTintColor = Brand.current().secondaryTintColor
        pageControl.hidden = true
        visualEffectContainer.contentView.addSubview(pageControl)
        constrain(pageControl, visualEffectContainer) { pageControl, container in
            pageControl.centerX == container.centerX
        }
    }
}