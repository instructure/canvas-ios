//
//  CanvasBackgroundView.swift
//  Parent
//
//  Created by Brandon Pluim on 1/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import QuartzCore

class CanvasBackgroundGradientView: UIView {
    var patternImageView : UIImageView!
    var gradientLayer : CAGradientLayer = CAGradientLayer()
    
    var tintTopColor : UIColor = UIColor(r: 213, g: 0, b: 119)
    
    var tintBottomColor : UIColor = UIColor(r: 81, g: 55, b: 204)
    
    var tintOpacity : Float = 0.9 {
        didSet { updateTintColor() }
    }
    
    init(frame: CGRect, tintTopColor: UIColor, tintBottomColor: UIColor) {
        self.tintTopColor = tintTopColor
        self.tintBottomColor = tintBottomColor
        
        super.init(frame: frame)
        
        initImageViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initImageViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initImageViews()
        updateTintColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // We need to do this here in order to
        updateTintColor()
    }
    
    func initImageViews() {
        patternImageView = UIImageView()
        patternImageView.translatesAutoresizingMaskIntoConstraints = false
        patternImageView.image = UIImage(named: "tri_pattern_portrait")
        
        addSubview(patternImageView)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": patternImageView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": patternImageView]))
    }
    
    func updateImageWithUITraitCollection(newCollection: UITraitCollection) {
        //TODO: we need to check this here
    }
    
    func transitionToColors(tintTopColor: UIColor, tintBottomColor: UIColor) {
        
        gradientLayer.colors = [tintTopColor.CGColor, tintBottomColor.CGColor]
        
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = [self.tintTopColor.CGColor, self.tintBottomColor.CGColor]
        colorAnimation.toValue = [tintTopColor.CGColor, tintBottomColor.CGColor]
        colorAnimation.duration = 0.5
        gradientLayer.addAnimation(colorAnimation, forKey: "colorAnimation")
        
        self.tintTopColor = tintTopColor
        self.tintBottomColor = tintBottomColor
    }
    
    func updateTintColor() {
        gradientLayer.frame = bounds
        gradientLayer.opacity = tintOpacity
        gradientLayer.removeFromSuperlayer()
        gradientLayer.colors = [tintTopColor.CGColor, tintBottomColor.CGColor]
        // Hoizontal - commenting these two lines will make the gradient veritcal
        gradientLayer.startPoint = CGPointMake(0.0, 1)
        gradientLayer.endPoint = CGPointMake(1.0, 0.0)
        layer.addSublayer(gradientLayer)
    }
    
}