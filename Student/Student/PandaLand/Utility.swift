//
//  Utilities.swift
//  Platformer
//
//  Created by MattBaranowski on 2/15/16.
//  Copyright © 2016 mattbaranowski. All rights reserved.
//

import SpriteKit

func * (a : CGPoint, b : CGPoint) -> CGPoint {
    return CGPoint(x: a.x * b.x,y: a.y * b.y)
}

func * (a : CGPoint, b : CGFloat) -> CGPoint {
    return CGPoint(x: a.x * b, y: a.y * b)
}

func * (a : CGPoint, b : Double) -> CGPoint {
    let f = CGFloat(b)
    return CGPoint(x: a.x * f, y: a.y * f)
}

func + (a : CGPoint, b : CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x,
        y: a.y + b.y)
}

func - (a : CGPoint, b : CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x, y: a.y - b.y)
}

func += ( a : inout CGPoint, b : CGPoint) {
    a = a + b
}

func *= ( a : inout CGPoint, b : CGPoint) {
    a = a * b
}

func min<T: Comparable>(a : T, b : T) -> T {
    return a < b
        ? a : b
}

func max<T: Comparable>(a : T, b : T) -> T {
    return a > b ? a : b
}

/// return point with maximum value for each component of a and b
func max(a : CGPoint, b : CGPoint) -> CGPoint {
    return CGPoint(x: max(a.x, b.x), y: max(a.y, b.y))
}

/// return point with maximum value for each component of a and b
func min(a : CGPoint, b : CGPoint) -> CGPoint {
    return CGPoint(x: min(a.x, b.x), y: min(a.y, b.y))
}

// return a value that is at least equal to `lower` and at most equal to `upper`
func clamp<T: Comparable>(lower : T, upper : T, _ a : T) -> T {
    return min( max(a, lower), upper)
}

func clamp(lower : CGPoint, upper : CGPoint, _ a : CGPoint) -> CGPoint {
    return CGPoint(x: clamp(lower:lower.x, upper:upper.x, a.x),
        y: clamp(lower:lower.y, upper:upper.y, a.y))
}

func delay(_ delay:Int, closure: DispatchWorkItem) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay), execute: closure)
}

extension SKNode {
    func addBoundingBoxNode() {
        let box = SKShapeNode(rect: CGRect(origin: CGPoint(x:-self.frame.size.width*0.5,y:-self.frame.size.height*0.5),
            size: self.frame.size))
        box.strokeColor = SKColor.red
        box.fillColor = SKColor.clear
        box.zPosition = self.zPosition + 1
        self.addChild(box)
    }
}

extension SKColor {
    public class func skyBlueColor() -> SKColor {
        return SKColor(red: 0.3, green: 0.5, blue: 0.95, alpha: 1)
    }

}
