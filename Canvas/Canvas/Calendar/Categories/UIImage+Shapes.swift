//
//  UIImage+Shapes.swift
//  Calendar
//
//  Created by Brandon Pluim on 2/10/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

extension UIImage {
    class func rectImage(frame frame: CGRect, color: UIColor, scale: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillRect(context!, frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    class func circleImage(frame frame: CGRect, color: UIColor, scale: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        
        var rect = frame
        rect.origin = CGPointZero
        
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillEllipseInRect(context!, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
        
    }
}
