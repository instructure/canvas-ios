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
    
    

import UIKit
import QuartzCore

open class TriangleBackgroundGradientView: UIImageView {
    var gradientLayer : CAGradientLayer = CAGradientLayer()

    var tintTopColor : UIColor = UIColor.clear
    var tintBottomColor : UIColor = UIColor.clear
    open var diagonal: Bool = true {
        didSet {
            updateTintColor()
        }
    }
    open var collection : UITraitCollection? {
        didSet {
            if let collection = collection {
                self.updateImage(collection)
            }
        }
    }

    open var tintOpacity : Float = 0.8 {
        didSet { updateTintColor() }
    }

    public init(frame: CGRect, tintTopColor: UIColor, tintBottomColor: UIColor) {
        self.tintTopColor = tintTopColor
        self.tintBottomColor = tintBottomColor

        super.init(frame: frame)

        commonInit()
        updateTintColor()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
        updateTintColor()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
        updateTintColor()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateTintColor()
    }

    func commonInit() {
        self.image = UIImage(named: "tri_pattern", in: Bundle(for: TriangleBackgroundGradientView.self), compatibleWith: collection)
        self.contentMode = .scaleAspectFill
    }

    open func updateImage(_ collection: UITraitCollection, coordinator: UIViewControllerTransitionCoordinator? = nil) {
        self.image = UIImage(named: "tri_pattern", in: Bundle(for: TriangleBackgroundGradientView.self), compatibleWith: collection)
        let transition = CATransition()
        transition.duration = coordinator?.transitionDuration ?? 1.0
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.layer.add(transition, forKey: nil)
    }

    open func transitionToColors(_ tintTopColor: UIColor, tintBottomColor: UIColor, duration: TimeInterval = 0.0) {

        gradientLayer.colors = [tintTopColor.cgColor, tintBottomColor.cgColor]

        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = [self.tintTopColor.cgColor, self.tintBottomColor.cgColor]
        colorAnimation.toValue = [tintTopColor.cgColor, tintBottomColor.cgColor]
        colorAnimation.duration = duration
        gradientLayer.add(colorAnimation, forKey: "colorAnimation")

        self.tintTopColor = tintTopColor
        self.tintBottomColor = tintBottomColor
    }

    func updateTintColor() {
        gradientLayer.frame = bounds
        gradientLayer.opacity = tintOpacity
        gradientLayer.removeFromSuperlayer()
        gradientLayer.colors = [tintTopColor.cgColor, tintBottomColor.cgColor]

        if diagonal {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        }
        
        layer.addSublayer(gradientLayer)
    }
    
}
