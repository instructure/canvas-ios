//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
    
    @objc public static func colorFromHexString(_ hex: String) -> UIColor? {
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
    
    @objc public var hex: String {
        let components = cgColor.components
        
        let r: CGFloat = components.red
        let g: CGFloat = components.green
        let b: CGFloat = components.blue
        
        let hex = String(format: "#%02X%02X%02X", UInt(round(r * 255)), UInt(round(g * 255)), UInt(round(b * 255)))

        return hex
    }

}
