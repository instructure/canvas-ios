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

public extension UIColor {
    @objc class var calendarTintColor: UIColor {
        return UIColor(red: 0.0/255.0, green: 142.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    }
    @objc class var calendarHighlightTintColor: UIColor {
        return UIColor(red: 179.0/255.0, green: 224.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    }
    
    @objc class var calendarDayCircleColor: UIColor {
        return UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    }
    
    @objc class var calendarDayDetailBackgroundColor: UIColor {
        return UIColor(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    }
    
    @objc class var calendarNoResultsTextColor: UIColor {
        return UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
    }
    
    @objc class var calendarDayOffTextColor: UIColor {
        return UIColor(red: 145.0/255.0, green: 145.0/255.0, blue: 145.0/255.0, alpha: 1.0)
    }
    
    @objc class var calendarDaysOfWeekBackgroundColor: UIColor {
        return UIColor(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    }
}
