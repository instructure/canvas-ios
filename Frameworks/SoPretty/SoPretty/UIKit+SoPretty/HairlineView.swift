//
//  HairlineView.swift
//  SoPretty
//
//  Created by Derrick Hathaway on 11/18/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation

public enum Orientation {
    case Vertical
    case Horizontal
}

public class HairlineView: UIView {
    
    public var color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2) {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            lineLayer.fillColor = color.CGColor
            CATransaction.commit()
        }
    }
    
    public var orientation: Orientation = .Horizontal {
        didSet {
            setNeedsLayout()
        }
    }
    
    lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = self.color.CGColor
        self.layer.addSublayer(layer)
        return layer
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let bounds = self.bounds
        let lineWidth = 1.0 / UIScreen.mainScreen().scale
        
        let rect: CGRect
        if orientation == .Vertical {
            rect = CGRect(origin: .zero, size: CGSize(width: lineWidth, height: bounds.size.height))
        } else {
            rect = CGRect(x: 0, y: bounds.height - lineWidth, width: bounds.width, height: lineWidth)
        }
        
        lineLayer.path = UIBezierPath(rect: rect).CGPath
        lineLayer.frame = bounds
        
        CATransaction.commit()
    }
}