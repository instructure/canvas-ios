
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

class CalendarDaysOfWeekView : UIView {
    
    var interitemSpacing: CGFloat = 2.0
    
    var dayOfWeekLabelFont: UIFont = UIFont(name: "HelveticaNeue", size: 10.0)!
    var dayOfWeekLabelTextColor: UIColor = UIColor.blackColor()
    var dayOffWeekLabelTextColor: UIColor = UIColor.calendarDayOffTextColor
    var calendar = NSCalendar.currentCalendar()
    
    
    private var weekdayLabels = [UILabel]()
    private var veryShortStandaloneWeekdaySymbols: [AnyObject]?
    private var shortStandaloneWeekdaySymbols: [AnyObject]?
    private var standaloneWeekdaySymbols: [AnyObject]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        backgroundColor = UIColor.calendarDaysOfWeekBackgroundColor
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        
        veryShortStandaloneWeekdaySymbols = dateFormatter.veryShortStandaloneWeekdaySymbols
        shortStandaloneWeekdaySymbols = dateFormatter.shortStandaloneWeekdaySymbols
        standaloneWeekdaySymbols = dateFormatter.standaloneWeekdaySymbols
        
        
        var weekdaySymbols: [AnyObject]?
        if isPhone() {
            weekdaySymbols = isPortrait() ? veryShortStandaloneWeekdaySymbols : shortStandaloneWeekdaySymbols
        } else {
            weekdaySymbols = isPortrait() ? shortStandaloneWeekdaySymbols : standaloneWeekdaySymbols
        }
        
        initializeWeekdayLabels(weekdaySymbols!)
    }
    
    func initializeWeekdayLabels(weekdaySymbols: [AnyObject]) {
        weekdayLabels.removeAll(keepCapacity: false)
        
        let dayOfWeekLabelBackgroundColor = UIColor.clearColor()
        for (index, weekdaySymbol) in weekdaySymbols.enumerate() {
            let weekdayLabel = UILabel()
            weekdayLabel.textAlignment = NSTextAlignment.Center
            weekdayLabel.backgroundColor = dayOfWeekLabelBackgroundColor
            weekdayLabel.font = dayOfWeekLabelFont
            weekdayLabel.text = weekdaySymbol as? String
            if index != 0 && index != 6 {
                weekdayLabel.textColor = dayOfWeekLabelTextColor
            } else {
                weekdayLabel.textColor = dayOffWeekLabelTextColor
            }
            addSubview(weekdayLabel)
            weekdayLabels.append(weekdayLabel)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutWeekdayLabels()
        self.updateWeekdayLabels()
    }
    
    func layoutWeekdayLabels() {
        let size = itemSize()
        
        let y: CGFloat = 0.0
        var x: CGFloat = 0.0
        for label in weekdayLabels {
            label.frame = CGRectMake(x, y, size.width, size.height)
            x += size.width + interitemSpacing
        }
    }
    
    func updateWeekdayLabels() {
        for (index, label) in weekdayLabels.enumerate() {
            label.font = dayOfWeekLabelFont
            label.text = self.textForIndex(index) as? String
        }
    }
    
    func textForIndex(index: Int) -> AnyObject {
        if isPhone() {
            let weekdaySymbols = isPortrait() ? veryShortStandaloneWeekdaySymbols! : shortStandaloneWeekdaySymbols!
            return weekdaySymbols[index]
        } else {
            let weekdaySymbols = isPortrait() ? shortStandaloneWeekdaySymbols! : standaloneWeekdaySymbols!
            return weekdaySymbols[index]
        }
    }
    
    func isPhone() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }
    
    func isPortrait() -> Bool {
        return UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
    }
    
    func itemSize() -> CGSize {
        let numberOfItems = numberOfDaysInWeek()
        let totalIteritemSpacing = interitemSpacing * CGFloat(numberOfItems - 1)
        var itemWidth = (CGRectGetWidth(self.frame) - totalIteritemSpacing)/CGFloat(numberOfItems)
        itemWidth = floor(itemWidth * 1000) / 1000
        let itemHeight = CGRectGetHeight(self.frame)
        
        return CGSizeMake(itemWidth, itemHeight)
        
    }
    
    func numberOfDaysInWeek() -> Int {
        return self.calendar.maximumRangeOfUnit(.Weekday).length
    }
    
}