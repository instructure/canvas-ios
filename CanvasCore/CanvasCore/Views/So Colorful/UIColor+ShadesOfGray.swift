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
