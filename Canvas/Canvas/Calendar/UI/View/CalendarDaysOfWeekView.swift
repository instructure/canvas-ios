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
    var dayOfWeekLabelTextColor: UIColor = UIColor.black
    var dayOffWeekLabelTextColor: UIColor = UIColor.calendarDayOffTextColor
    var calendar = Calendar.current
    
    
    fileprivate var weekdayLabels = [UILabel]()
    fileprivate var veryShortStandaloneWeekdaySymbols: [Any]?
    fileprivate var shortStandaloneWeekdaySymbols: [Any]?
    fileprivate var standaloneWeekdaySymbols: [Any]?
    
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        
        veryShortStandaloneWeekdaySymbols = dateFormatter.veryShortStandaloneWeekdaySymbols as [Any]?
        shortStandaloneWeekdaySymbols = dateFormatter.shortStandaloneWeekdaySymbols as [Any]?
        standaloneWeekdaySymbols = dateFormatter.standaloneWeekdaySymbols as [Any]?
        
        
        var weekdaySymbols: [Any]?
        if isPhone() {
            weekdaySymbols = isPortrait() ? veryShortStandaloneWeekdaySymbols : shortStandaloneWeekdaySymbols
        } else {
            weekdaySymbols = isPortrait() ? shortStandaloneWeekdaySymbols : standaloneWeekdaySymbols
        }
        
        initializeWeekdayLabels(weekdaySymbols!)
    }
    
    func initializeWeekdayLabels(_ weekdaySymbols: [Any]) {
        weekdayLabels.removeAll(keepingCapacity: false)
        
        let dayOfWeekLabelBackgroundColor = UIColor.clear
        for (index, weekdaySymbol) in weekdaySymbols.enumerated() {
            let weekdayLabel = UILabel()
            weekdayLabel.textAlignment = NSTextAlignment.center
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
            label.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            x += size.width + interitemSpacing
        }
    }
    
    func updateWeekdayLabels() {
        for (index, label) in weekdayLabels.enumerated() {
            label.font = dayOfWeekLabelFont
            label.text = self.textForIndex(index) as? String
        }
    }
    
    func textForIndex(_ index: Int) -> Any {
        if isPhone() {
            let weekdaySymbols = isPortrait() ? veryShortStandaloneWeekdaySymbols! : shortStandaloneWeekdaySymbols!
            return weekdaySymbols[index]
        } else {
            let weekdaySymbols = isPortrait() ? shortStandaloneWeekdaySymbols! : standaloneWeekdaySymbols!
            return weekdaySymbols[index]
        }
    }
    
    func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    func isPortrait() -> Bool {
        return UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
    }
    
    func itemSize() -> CGSize {
        let numberOfItems = numberOfDaysInWeek()
        let totalIteritemSpacing = interitemSpacing * CGFloat(numberOfItems - 1)
        var itemWidth = (self.frame.width - totalIteritemSpacing)/CGFloat(numberOfItems)
        itemWidth = floor(itemWidth * 1000) / 1000
        let itemHeight = self.frame.height
        
        return CGSize(width: itemWidth, height: itemHeight)
        
    }
    
    func numberOfDaysInWeek() -> Int {
        return (self.calendar as NSCalendar).maximumRange(of: .weekday).length
    }
    
}
