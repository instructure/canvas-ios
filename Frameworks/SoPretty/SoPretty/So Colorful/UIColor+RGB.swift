//
//  UIColor+RGB.swift
//  SoPretty
//
//  Created by Brandon Pluim on 3/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension UIColor {
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(r: r, g: g, b: b, a:1.0)
    }

    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
}