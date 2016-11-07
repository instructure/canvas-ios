//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
