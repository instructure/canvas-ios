//
//  UIColor+LightenUpOkay.swift
//
//
//  Created by Derrick Hathaway on 9/24/15.
//
//

import UIKit

extension UIColor {
    public func lighterShade() -> UIColor {
        var a: CGFloat = 0.0
        var b: CGFloat = 0.0
        var c: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        if getHue(&a, saturation: &b, brightness: &c, alpha: &alpha) {
            return UIColor(hue: a, saturation: 0.2, brightness: 1.0, alpha: 1.0)
        }
        
        if getRed(&a, green: &b, blue: &c, alpha: &alpha) {
            let scale = 1.0 / max(a, max(b, c))
            return UIColor(red: scale * a, green: scale * b, blue: scale * c, alpha: 1.0)
        }
        
        return UIColor.prettyLightGray()
    }
}
