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
import CoreImage

extension CGColor {
    public var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let ciColor = CIColor(cgColor: self)
        return (ciColor.red, ciColor.green, ciColor.blue, ciColor.alpha)
    }
}

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
    
    public var hex: String {
        let components = cgColor.components
        
        let r: CGFloat = components.red
        let g: CGFloat = components.green
        let b: CGFloat = components.blue
        
        let hex = String(format: "#%02X%02X%02X", UInt(round(r * 255)), UInt(round(g * 255)), UInt(round(b * 255)))

        return hex
    }

}
