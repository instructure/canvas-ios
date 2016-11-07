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

class IconTodayView : UIView {
    
    @IBOutlet weak var lblDayOfMonth: UILabel!
    @IBOutlet weak var imgIconBackground: UIImageView!
    
    
    class func instantiateFromNib(date: NSDate, tintColor: UIColor?, target: AnyObject, action: Selector) -> IconTodayView? {
        if let todayView = IconTodayView.loadFromNibNamed("IconTodayView", bundle: IconTodayView.bundle) as? IconTodayView {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "d"
            todayView.lblDayOfMonth.text = dateFormatter.stringFromDate(date)
            
            let calendarImage = UIImage(named: "icon_today", inBundle: IconTodayView.bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            todayView.imgIconBackground.image = calendarImage
            todayView.imgIconBackground.tintColor = tintColor
            
            todayView.lblDayOfMonth.textColor = tintColor
            todayView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
            
            return todayView
        }
        
        return nil
    }
}