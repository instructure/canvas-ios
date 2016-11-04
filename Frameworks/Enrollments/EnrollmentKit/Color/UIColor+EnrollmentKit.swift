
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
    
    

import Foundation

extension UIColor {
    
    public static func colorFromHexString(hex: String) -> UIColor? {
        let justTheNumber = hex
            .stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
            .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "#"))
        
        let digitCount = justTheNumber.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        var number = UInt32(0)
        guard NSScanner(string: justTheNumber).scanHexInt(&number) else { return nil }
        
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
    
    public var hex: String {
        let components = CGColorGetComponents(CGColor)
        
        let r: CGFloat = components[0]
        let g: CGFloat = components[1]
        let b: CGFloat = components[2]
        
        let hex = String(format: "#%02X%02X%02X", UInt(round(r * 255)), UInt(round(g * 255)), UInt(round(b * 255)))

        return hex
    }
    
    //Main 15 Colors
    public class func contextRed() -> UIColor {
        return UIColor(red: 0xEF/255.0, green: 0x44/255.0, blue: 0x37/255.0, alpha: 1.0)
    }
    public class func contextPink() -> UIColor {
        return UIColor(red: 0xE7/255.0, green: 0x1F/255.0, blue: 0x63/255.0, alpha: 1.0)
    }
    public class func contextPurple() -> UIColor {
        return UIColor(red: 0x8F/255.0, green: 0x3E/255.0, blue: 0x97/255.0, alpha: 1.0)
    }
    public class func contextDeepPurple() -> UIColor {
        return UIColor(red: 0x65/255.0, green: 0x49/255.0, blue: 0x9D/255.0, alpha: 1.0)
    }
    public class func contextIndigo() -> UIColor {
        return UIColor(red: 0x45/255.0, green: 0x54/255.0, blue: 0xA4/255.0, alpha: 1.0)
    }
    public class func contextBlue() -> UIColor {
        return UIColor(red: 0x20/255.0, green: 0x83/255.0, blue: 0xC5/255.0, alpha: 1.0)
    }
    public class func contextLightBlue() -> UIColor {
        return UIColor(red: 0x35/255.0, green: 0xA4/255.0, blue: 0xDC/255.0, alpha: 1.0)
    }
    public class func contextCyan() -> UIColor {0
        return UIColor(red: 0x09/255.0, green: 0xBC/255.0, blue: 0xD3/255.0, alpha: 1.0)
    }
    public class func contextTeal() -> UIColor {
        return UIColor(red: 0x00/255.0, green: 0x96/255.0, blue: 0x88/255.0, alpha: 1.0)
    }
    public class func contextGreen() -> UIColor {
        return UIColor(red: 0x43/255.0, green: 0xA0/255.0, blue: 0x47/255.0, alpha: 1.0)
    }
    public class func contextLightGreen() -> UIColor {
        return UIColor(red: 0x8B/255.0, green: 0xC3/255.0, blue: 0x4A/255.0, alpha: 1.0)
    }
    public class func contextYellow() -> UIColor {
        return UIColor(red: 0xFD/255.0, green: 0xC0/255.0, blue: 0x10/255.0, alpha: 1.0)
    }
    public class func contextOrange() -> UIColor {
        return UIColor(red: 0xF8/255.0, green: 0x97/255.0, blue: 0x1C/255.0, alpha: 1.0)
    }
    public class func contextDeepOrange() -> UIColor {
        return UIColor(red: 0xF0/255.0, green: 0x59/255.0, blue: 0x2B/255.0, alpha: 1.0)
    }
    public class func contextLightPink() -> UIColor {
        return UIColor(red: 0xF0/255.0, green: 0x62/255.0, blue: 0x91/255.0, alpha: 1.0)
    }
}