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

class IconTodayView : UIView {
    
    @IBOutlet weak var lblDayOfMonth: UILabel!
    @IBOutlet weak var imgIconBackground: UIImageView!
    
    
    @objc class func instantiateFromNib(_ date: Date, tintColor: UIColor?, target: Any, action: Selector) -> IconTodayView? {
        if let todayView = IconTodayView.loadFromNibNamed("IconTodayView", bundle: IconTodayView.bundle) as? IconTodayView {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d"
            todayView.lblDayOfMonth.text = dateFormatter.string(from: date)
            
            let calendarImage = UIImage.icon(.calendarEmpty)
            todayView.imgIconBackground.image = calendarImage
            todayView.imgIconBackground.tintColor = tintColor
            
            todayView.lblDayOfMonth.textColor = tintColor
            todayView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))

            todayView.isAccessibilityElement = true
            todayView.accessibilityTraits = UIAccessibilityTraits.button
            todayView.accessibilityLabel = NSLocalizedString("Today", comment: "Button to scroll to 'today' on the calendar")
            
            return todayView
        }
        
        return nil
    }
}
