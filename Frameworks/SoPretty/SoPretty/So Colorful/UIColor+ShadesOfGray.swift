//
//  UIColor+ShadesOfGray.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 7/15/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

extension UIColor {
    public class func prettyErrorColor() -> UIColor {
        return UIColor(hue: 0, saturation: 0.75, brightness: 0.75, alpha: 1.0)
    }
    
    public class func prettyBlack() -> UIColor {
        return UIColor(white: 0.1, alpha: 1)
    }
    
    public class func prettyGray() -> UIColor {
        return UIColor(white: 0.6667, alpha: 1.0)
    }
    
    /// 92% (235/255)
    public class func prettyLightGray() -> UIColor {
        return UIColor(white: 0.92, alpha: 1.0)
    }
    
    public class func prettyOffWhite() -> UIColor {
        return UIColor(white: 0.98, alpha: 1.0)
    }
}