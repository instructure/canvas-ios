//
//  UIColorExtensions.swift
//  Teacher
//
//  Created by Garrett Richards on 5/5/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation

extension UIColor {
    public static func colorFromHexString(_ hex: String) -> UIColor? {
        let justTheNumber = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        
        let digitCount = justTheNumber.lengthOfBytes(using: String.Encoding.utf8)
        
        var number = UInt32(0)
        guard Scanner(string: justTheNumber).scanHexInt32(&number) else { return nil }
        
        let mask: UInt32, shift: UInt32
        if digitCount == 3 {
            mask = 0xF
            shift = 4
        } else {
            mask = 0xFF
            shift = 8
        }
        
        var b = number & mask
        
        number >>= shift
        var g = number & mask
        
        number >>= shift
        var r = number & mask
        
        if digitCount == 3 {
            r |= (r << shift)
            g |= (g << shift)
            b |= (b << shift)
        }
        
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1.0)
    }
}
