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

//
//  UIColor+LightenUpOkay.swift
//
//
//  Created by Derrick Hathaway on 9/24/15.
//
//

import UIKit

extension UIColor {
    @objc public func lighterShade() -> UIColor {
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
