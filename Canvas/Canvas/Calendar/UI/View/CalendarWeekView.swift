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
    var buttonFont = UIFont(name: "HelveticaNeue-Bold", size: 10.0)!
    
    // text colors
    var buttonTextColor = UIColor.black
    var offButtonTextColor = UIColor.calendarDayOffTextColor
    var buttonSelectedTextColor: UIColor = .white
    var buttonHighlightedTextColor: UIColor = .white
    
    
    var dateFormatter = DateFormatter()
    lazy var calendar = Calendar.current
    
    var selectedDay: Date?
    var initialDay = Date()
    
    fileprivate var weekButtons = [UIButton]()
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
        dateFormatter.dateFormat = "d"
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        
        
        veryShortStandaloneWeekdaySymbols = dateFormatter.veryShortStandaloneWeekdaySymbols as [Any]?
        shortStandaloneWeekdaySymbols = dateFormatter.shortStandaloneWeekdaySymbols as [Any]?
        standaloneWeekdaySymbols = dateFormatter.standaloneWeekdaySymbols as [Any]?
        
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
        self.updateBackgroundImages()
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
    
    func updateBackgroundImages() {
        let normalCircleImage = self.itemCircleImage(self.normalCircleColor)
        let selectedCirlceImage = self.itemCircleImage(self.selectedCircleColor)
        let highlightCircleImage = self.itemCircleImage(self.highlightCircleColor)
        
        for button in weekButtons {
            button.setBackgroundImage(normalCircleImage, for: UIControlState())
            button.setBackgroundImage(selectedCirlceImage, for: UIControlState.selected)
            button.setBackgroundImage(highlightCircleImage, for: UIControlState.highlighted)
        }
    }
    
    func textForIndex(_ index: Int) -> String? {
        
        if isPhone() {
            let weekdaySymbols = isPortrait() ? veryShortStandaloneWeekdaySymbols! : shortStandaloneWeekdaySymbols!
            return weekdaySymbols[index] as? String
        } else {
            let weekdaySymbols = isPortrait() ? shortStandaloneWeekdaySymbols! : standaloneWeekdaySymbols!
            return weekdaySymbols[index] as? String
        }
    }
    
    func dateForIndex(_ index: Int) -> Date {
        var weekComponents = (calendar as NSCalendar).components([.year, .month, .weekOfYear, .weekday], from: self.initialDay)
        weekComponents.weekday = index + 1
        return calendar.date(from: weekComponents)!
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
        return (calendar as NSCalendar).maximumRange(of: .weekday).length
    }
    
    func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    func isPortrait() -> Bool {
        return UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
    }
    

    fileprivate func itemCircleImage(_ color: UIColor) -> UIImage {
        let itemDim = itemSize()
        let itemDimention = itemDim.height > itemDim.width ? itemDim.width - 10 : itemDim.height - 10
        let itemSz = CGSize(width: itemDimention, height: itemDimention)
        let rect = CGRect(x: itemDim.width/2 - itemSz.width/2, y: itemDim.height/2 - itemSz.height/2, width: itemSz.width, height: itemSz.height)
        
        UIGraphicsBeginImageContextWithOptions(itemDim, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()
        context!.setFillColor(color.cgColor)
        context!.fillEllipse(in: rect)
        context!.restoreGState()
        let returnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return returnImage!

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
