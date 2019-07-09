//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit

extension UIImage {
    @objc class func rectImage(frame: CGRect, color: UIColor, scale: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    @objc class func circleImage(frame: CGRect, color: UIColor, scale: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        
        var rect = frame
        rect.origin = CGPoint.zero
        
        context!.setFillColor(color.cgColor)
        context!.fillEllipse(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
        
    }
}
