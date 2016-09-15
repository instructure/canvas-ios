//
//  CALayer+Circle.swift
//  SoPretty
//
//  Created by Nathan Lambson on 3/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

private let pi = CGFloat(M_PI) // just cast it dang it <twitching eye>

public extension CAShapeLayer {
    static func pathForAngle(angle: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        // starting point
        let graphCenterRadius = CGFloat(62)
        let startingPoint = CGPoint(x: graphCenterRadius, y: 0)
        path.moveToPoint(startingPoint)
        
        path.addArcWithCenter(.zero, radius: graphCenterRadius, startAngle: 0, endAngle: angle, clockwise: true)
        
        path.applyTransform(CGAffineTransformMakeRotation(pi/2.0 + (2.0*pi-angle)/2.0))
        return path
    }
    
    static func layerForCircleView(width: CGFloat = 16.0, color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = pathForAngle(1.5 * pi).CGPath
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = color.CGColor
        layer.lineWidth = width
        layer.lineCap = kCALineCapButt
        
        return layer
    }
}