//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import Cartography


class QuizIntroFooterView: UIView {
    @objc let takeButton = UIButton()
    fileprivate let takeabilityActivityIndicator = UIActivityIndicatorView()

    fileprivate var takeButtonConstraintGroup = ConstraintGroup()

    fileprivate let visualEffectContainer = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isOpaque = false
        backgroundColor = UIColor.clear
        
        prepareBackgroundView()
        prepareTakeButton()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: Layout

extension QuizIntroFooterView {
    @objc func setTakeButtonOnscreen(_ onscreen: Bool, animated: Bool) {
        if onscreen {
            constrain(takeButton, visualEffectContainer.contentView, replace: takeButtonConstraintGroup) { takeButton, contentView in
                takeButton.centerY == contentView.centerY
            }
        } else {
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
    @objc func prepareBackgroundView() {
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
                takeButton.setImage(nil, for: UIControl.State())
                takeButton.setTitle("", for: UIControl.State())
                
                takeabilityActivityIndicator.isHidden = false
                takeabilityActivityIndicator.startAnimating()
            } else {
                let lockImage = UIImage(named: "quiz-lock", in: Bundle(for: QuizIntroViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                takeButton.imageView?.tintColor = UIColor.white
                takeButton.setImage(lockImage, for: UIControl.State())
                takeButton.setTitle(nil, for: UIControl.State())
                
                takeabilityActivityIndicator.stopAnimating()
                takeabilityActivityIndicator.isHidden = true
            }
            
        default:
            takeButton.setImage(nil, for: UIControl.State())
            takeButton.setTitle(takeability.label, for: UIControl.State())
            
            takeabilityActivityIndicator.stopAnimating()
            takeabilityActivityIndicator.isHidden = true
        }
    }
    
    fileprivate func prepareTakeButton() {
        takeButton.backgroundColor = Brand.current.tintColor
        takeButton.layer.cornerRadius = 5.0
        takeButton.isEnabled = false
        takeButton.accessibilityIdentifier = "Quiz.takeButton"
        
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
