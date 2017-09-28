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


protocol CalendarWeekViewDelegate {
    func weekView(_ weekView: CalendarWeekView, selectedDate day: Date)
}

class CalendarWeekView : UIView {
    var delegate: CalendarWeekViewDelegate?
    var interitemSpacing: CGFloat = 2.0
    
    var labelBackgroundColor = UIColor.clear
    
    // circle colors
    var normalCircleColor = UIColor.clear
    var selectedCircleColor =  UIColor.calendarTintColor
    var highlightCircleColor = UIColor.calendarHighlightTintColor
    
    // font
    var buttonFont = UIFont.preferredFont(forTextStyle: .title3).noLargerThan(32.0)
    
    // text colors
    var buttonTextColor = UIColor.black
    var offButtonTextColor = UIColor.calendarDayOffTextColor
    var buttonSelectedTextColor: UIColor = .contextPink()
    var buttonHighlightedTextColor: UIColor = .contextLightPink()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.calendar = Calendar.current
        formatter.locale = Calendar.current.locale
        return formatter
    }()
    
    var selectedDay: Date?
    var initialDay = Date()
    
    fileprivate var weekButtons = [UIButton]()
    fileprivate lazy var veryShortStandaloneWeekdaySymbols: [String] = {
        return self.dateFormatter.veryShortStandaloneWeekdaySymbols
    }()
    fileprivate lazy var shortStandaloneWeekdaySymbols: [String] = {
       return self.dateFormatter.shortStandaloneWeekdaySymbols
    }()
    fileprivate lazy var standaloneWeekdaySymbols: [String] = {
        return self.dateFormatter.standaloneWeekdaySymbols
    }()
    
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
        initializeWeekdayLabels()
    }
    
    func initializeWeekdayLabels() {
        weekButtons.removeAll(keepingCapacity: false)
        
        for index in 0..<numberOfDaysInWeek() {
            let button = dayOfWeekButton(index)
            addSubview(button)
            weekButtons.append(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutWeekdayLabels()
        self.updateWeekdayLabels(false)
    }
    
    func dayButtonPressed(_ button: UIButton) {
        if let delegate = delegate {
            let index = button.tag
            delegate.weekView(self, selectedDate: dateForIndex(index))
        }
    }
    
    func layoutWeekdayLabels() {
        let size = itemSize()
        
        let y: CGFloat = 0.0
        var x: CGFloat = interitemSpacing/2
        for button in weekButtons {
            button.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            button.layer.cornerRadius = size.height/2
            x += size.width + interitemSpacing
        }
    }
    
    func updateWeekdayLabels(_ animated: Bool) {
        for button in self.weekButtons {
            let index = button.tag
            button.setTitle(self.textForIndex(index), for: UIControlState())
            if let day = self.selectedDay {
                let isSelectedDay = self.dateForIndex(index).compare(day) == ComparisonResult.orderedSame
                if isSelectedDay {
                    button.isSelected = true
                } else {
                    button.isSelected = false
                }
            } else {
                button.isSelected = false
            }
        }
    }
    
    func textForIndex(_ index: Int) -> String {
        
        if isPhone() {
            return veryShortStandaloneWeekdaySymbols[index]
        } else {
            let weekdaySymbols = isPortrait() ? shortStandaloneWeekdaySymbols : standaloneWeekdaySymbols
            return weekdaySymbols[index]
        }
    }
    
    func dateForIndex(_ index: Int) -> Date {
        var weekComponents = (Calendar.current as NSCalendar).components([.year, .month, .weekOfYear, .weekday], from: self.initialDay)
        weekComponents.weekday = index + 1
        return Calendar.current.date(from: weekComponents)!
    }
    
    func setSelectedWeekdayIndex(_ index: Int, animated: Bool) {
        self.selectedDay = self.dateForIndex(index)
        self.updateWeekdayLabels(animated)
    }
    
    func setInitialDay(_ day: Date, animated: Bool) {
        self.initialDay = day
        self.updateWeekdayLabels(animated)
    }
    
    func setSelectedDay(_ day: Date?, animated: Bool) {
        self.selectedDay = day
        self.updateWeekdayLabels(animated)
    }
    
    func itemSize() -> CGSize {
        let numberOfItems = numberOfDaysInWeek()
        let totalIteritemSpacing = interitemSpacing * CGFloat(numberOfItems)
        var itemWidth = (self.frame.width - totalIteritemSpacing)/CGFloat(numberOfItems)
        itemWidth = floor(itemWidth * 1000) / 1000
        let itemHeight = self.frame.height
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func numberOfDaysInWeek() -> Int {
        return (Calendar.current as NSCalendar).maximumRange(of: .weekday).length
    }
    
    func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    func isPortrait() -> Bool {
        return UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
    }
    
    fileprivate func dayOfWeekButton(_ index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.addTarget(self, action:#selector(CalendarWeekView.dayButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        if index != 0 && index != 6 {
            button.setTitleColor(self.buttonTextColor, for: UIControlState())
        } else {
            button.setTitleColor(self.offButtonTextColor, for: UIControlState())
        }
        button.setTitleColor(buttonSelectedTextColor, for: .selected)
        button.setTitleColor(buttonHighlightedTextColor, for: .highlighted)
        button.contentMode = UIViewContentMode.center
        button.imageView?.contentMode = UIViewContentMode.center
        button.backgroundColor = self.labelBackgroundColor
        button.titleLabel!.font = self.buttonFont
        button.tag = index
        return button
    }
}
