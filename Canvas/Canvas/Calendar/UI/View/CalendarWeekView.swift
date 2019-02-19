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
    @objc var interitemSpacing: CGFloat = 2.0
    
    @objc var labelBackgroundColor = UIColor.clear
    
    // circle colors
    @objc var normalCircleColor = UIColor.clear
    @objc var selectedCircleColor =  UIColor.calendarTintColor
    @objc var highlightCircleColor = UIColor.calendarHighlightTintColor
    
    // font
    @objc var buttonFont = UIFont.preferredFont(forTextStyle: .title3).noLargerThan(32.0)
    
    // text colors
    @objc var buttonTextColor = UIColor.black
    @objc var offButtonTextColor = UIColor.calendarDayOffTextColor
    @objc var buttonSelectedTextColor: UIColor = .contextPink()
    @objc var buttonHighlightedTextColor: UIColor = .contextLightPink()
    
    @objc lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.calendar = Calendar.current
        formatter.locale = Calendar.current.locale
        return formatter
    }()
    
    @objc var selectedDay: Date?
    @objc var initialDay = Date()
    
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
    
    @objc func initialize() {
        backgroundColor = UIColor.calendarDaysOfWeekBackgroundColor
        initializeWeekdayLabels()
    }
    
    @objc func initializeWeekdayLabels() {
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
    
    @objc func dayButtonPressed(_ button: UIButton) {
        if let delegate = delegate {
            let index = button.tag
            delegate.weekView(self, selectedDate: dateForIndex(index))
        }
    }
    
    @objc func layoutWeekdayLabels() {
        let size = itemSize()
        
        let y: CGFloat = 0.0
        var x: CGFloat = interitemSpacing/2
        for button in weekButtons {
            button.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            button.layer.cornerRadius = size.height/2
            x += size.width + interitemSpacing
        }
    }
    
    @objc func updateWeekdayLabels(_ animated: Bool) {
        for button in self.weekButtons {
            let index = button.tag
            button.setTitle(self.textForIndex(index), for: UIControl.State())
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
    
    @objc func textForIndex(_ index: Int) -> String {
        
        if isPhone() {
            return veryShortStandaloneWeekdaySymbols[index]
        } else {
            let weekdaySymbols = isPortrait() ? shortStandaloneWeekdaySymbols : standaloneWeekdaySymbols
            return weekdaySymbols[index]
        }
    }
    
    @objc func dateForIndex(_ index: Int) -> Date {
        var weekComponents = (Calendar.current as NSCalendar).components([.year, .month, .weekOfYear, .weekday], from: self.initialDay)
        weekComponents.weekday = index + 1
        return Calendar.current.date(from: weekComponents)!
    }
    
    @objc func setSelectedWeekdayIndex(_ index: Int, animated: Bool) {
        self.selectedDay = self.dateForIndex(index)
        self.updateWeekdayLabels(animated)
    }
    
    @objc func setInitialDay(_ day: Date, animated: Bool) {
        self.initialDay = day
        self.updateWeekdayLabels(animated)
    }
    
    @objc func setSelectedDay(_ day: Date?, animated: Bool) {
        self.selectedDay = day
        self.updateWeekdayLabels(animated)
    }
    
    @objc func itemSize() -> CGSize {
        let numberOfItems = numberOfDaysInWeek()
        let totalIteritemSpacing = interitemSpacing * CGFloat(numberOfItems)
        var itemWidth = (self.frame.width - totalIteritemSpacing)/CGFloat(numberOfItems)
        itemWidth = floor(itemWidth * 1000) / 1000
        let itemHeight = self.frame.height
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    @objc func numberOfDaysInWeek() -> Int {
        return (Calendar.current as NSCalendar).maximumRange(of: .weekday).length
    }
    
    @objc func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    @objc func isPortrait() -> Bool {
        return UIDevice.current.orientation.isPortrait
    }
    
    fileprivate func dayOfWeekButton(_ index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.addTarget(self, action:#selector(CalendarWeekView.dayButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        if index != 0 && index != 6 {
            button.setTitleColor(self.buttonTextColor, for: UIControl.State())
        } else {
            button.setTitleColor(self.offButtonTextColor, for: UIControl.State())
        }
        button.setTitleColor(buttonSelectedTextColor, for: .selected)
        button.setTitleColor(buttonHighlightedTextColor, for: .highlighted)
        button.contentMode = UIView.ContentMode.center
        button.imageView?.contentMode = UIView.ContentMode.center
        button.backgroundColor = self.labelBackgroundColor
        button.titleLabel!.font = self.buttonFont
        button.tag = index
        return button
    }
}
