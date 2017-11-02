//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import Cartography


class QuizIntroFooterView: UIView {
    let pageControl = UIPageControl()
    let takeButton = UIButton()
    fileprivate let takeabilityActivityIndicator = UIActivityIndicatorView()
    
    fileprivate var pageControlConstraintGroup = ConstraintGroup()
    fileprivate var takeButtonConstraintGroup = ConstraintGroup()

    fileprivate let visualEffectContainer = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isOpaque = false
        backgroundColor = UIColor.clear
        
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
    func setTakeButtonOnscreen(_ onscreen: Bool, animated: Bool) {
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
            UIView.animate(withDuration: 0.2, animations: visualEffectContainer.layoutIfNeeded)
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
    func takeabilityUpdated(_ takeability: Takeability) {
        // get the last page, set it to show the big blue button
        switch takeability {
        case .notTakeable(let reason):
            if reason == .undecided {
                takeButton.setImage(nil, for: UIControlState())
                takeButton.setTitle("", for: UIControlState())
                
                takeabilityActivityIndicator.isHidden = false
                takeabilityActivityIndicator.startAnimating()
            } else {
                let lockImage = UIImage(named: "quiz-lock", in: Bundle(for: QuizIntroViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                takeButton.imageView?.tintColor = UIColor.white
                takeButton.setImage(lockImage, for: UIControlState())
                takeButton.setTitle(nil, for: UIControlState())
                
                takeabilityActivityIndicator.stopAnimating()
                takeabilityActivityIndicator.isHidden = true
            }
            
        default:
            takeButton.setImage(nil, for: UIControlState())
            takeButton.setTitle(takeability.label, for: UIControlState())
            
            takeabilityActivityIndicator.stopAnimating()
            takeabilityActivityIndicator.isHidden = true
        }
    }
    
    fileprivate func prepareTakeButton() {
        takeButton.backgroundColor = Brand.current.tintColor
        takeButton.layer.cornerRadius = 5.0
        takeButton.isEnabled = false
        
        visualEffectContainer.contentView.addSubview(takeButton)
        
        constrain(takeButton, visualEffectContainer.contentView) { takeButton, container in
            takeButton.leading  == container.leading + 20
            takeButton.trailing == container.trailing - 20
            takeButton.height   == 44.0
        }
        
        takeabilityActivityIndicator.isHidden = true
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
    fileprivate func preparePageControl() {
        pageControl.pageIndicatorTintColor = Brand.current.tintColor
        pageControl.currentPageIndicatorTintColor = Brand.current.secondaryTintColor
        pageControl.isHidden = true
        visualEffectContainer.contentView.addSubview(pageControl)
        constrain(pageControl, visualEffectContainer) { pageControl, container in
            pageControl.centerX == container.centerX
        }
    }
}
