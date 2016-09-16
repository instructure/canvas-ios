//
//  CalendarWeekView.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit


protocol CalendarWeekViewDelegate {
    func weekView(weekView: CalendarWeekView, selectedDate day: NSDate)
}

class CalendarWeekView : UIView {
    var delegate: CalendarWeekViewDelegate?
    var interitemSpacing: CGFloat = 2.0
    
    var labelBackgroundColor = UIColor.clearColor()
    
    // circle colors
    var normalCircleColor = UIColor.clearColor()
    var selectedCircleColor =  UIColor.calendarTintColor
    var highlightCircleColor = UIColor.calendarHighlightTintColor
    
    // font
    var buttonFont = UIFont(name: "HelveticaNeue-Bold", size: 10.0)!
    
    // text colors
    var buttonTextColor = UIColor.blackColor()
    var offButtonTextColor = UIColor.calendarDayOffTextColor
    var buttonSelectedTextColor = UIColor.whiteColor()
    var buttonHighlightedTextColor = UIColor.whiteColor()
    
    
    var dateFormatter = NSDateFormatter()
    lazy var calendar = NSCalendar.currentCalendar()
    
    var selectedDay: NSDate?
    var initialDay = NSDate()
    
    private var weekButtons = [UIButton]()
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
        dateFormatter.dateFormat = "d"
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        
        
        veryShortStandaloneWeekdaySymbols = dateFormatter.veryShortStandaloneWeekdaySymbols
        shortStandaloneWeekdaySymbols = dateFormatter.shortStandaloneWeekdaySymbols
        standaloneWeekdaySymbols = dateFormatter.standaloneWeekdaySymbols
        
        backgroundColor = UIColor.calendarDaysOfWeekBackgroundColor
        initializeWeekdayLabels()
    }
    
    func initializeWeekdayLabels() {
        weekButtons.removeAll(keepCapacity: false)
        
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
    
    func dayButtonPressed(button: UIButton) {
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
            button.frame = CGRectMake(x, y, size.width, size.height)
            button.layer.cornerRadius = size.height/2
            x += size.width + interitemSpacing
        }
    }
    
    func updateWeekdayLabels(animated: Bool) {
        for button in self.weekButtons {
            let index = button.tag
            button.setTitle(self.textForIndex(index), forState: UIControlState.Normal)
            if let day = self.selectedDay {
                let isSelectedDay = self.dateForIndex(index).compare(day) == NSComparisonResult.OrderedSame
                if isSelectedDay {
                    button.selected = true
                } else {
                    button.selected = false
                }
            } else {
                button.selected = false
            }
        }
    }
    
    func updateBackgroundImages() {
        let normalCircleImage = self.itemCircleImage(self.normalCircleColor)
        let selectedCirlceImage = self.itemCircleImage(self.selectedCircleColor)
        let highlightCircleImage = self.itemCircleImage(self.highlightCircleColor)
        
        for button in weekButtons {
            button.setBackgroundImage(normalCircleImage, forState: UIControlState.Normal)
            button.setBackgroundImage(selectedCirlceImage, forState: UIControlState.Selected)
            button.setBackgroundImage(highlightCircleImage, forState: UIControlState.Highlighted)
        }
    }
    
    func textForIndex(index: Int) -> String? {
        
        if isPhone() {
            let weekdaySymbols = isPortrait() ? veryShortStandaloneWeekdaySymbols! : shortStandaloneWeekdaySymbols!
            return weekdaySymbols[index] as? String
        } else {
            let weekdaySymbols = isPortrait() ? shortStandaloneWeekdaySymbols! : standaloneWeekdaySymbols!
            return weekdaySymbols[index] as? String
        }
    }
    
    func dateForIndex(index: Int) -> NSDate {
        let weekComponents = calendar.components([.Year, .Month, .WeekOfYear, .Weekday], fromDate: self.initialDay)
        weekComponents.weekday = index + 1
        return calendar.dateFromComponents(weekComponents)!
    }
    
    func setSelectedWeekdayIndex(index: Int, animated: Bool) {
        self.selectedDay = self.dateForIndex(index)
        self.updateWeekdayLabels(animated)
    }
    
    func setInitialDay(day: NSDate, animated: Bool) {
        self.initialDay = day
        self.updateWeekdayLabels(animated)
    }
    
    func setSelectedDay(day: NSDate?, animated: Bool) {
        self.selectedDay = day
        self.updateWeekdayLabels(animated)
    }
    
    func itemSize() -> CGSize {
        let numberOfItems = numberOfDaysInWeek()
        let totalIteritemSpacing = interitemSpacing * CGFloat(numberOfItems)
        var itemWidth = (CGRectGetWidth(self.frame) - totalIteritemSpacing)/CGFloat(numberOfItems)
        itemWidth = floor(itemWidth * 1000) / 1000
        let itemHeight = CGRectGetHeight(self.frame)
        
        return CGSizeMake(itemWidth, itemHeight)
        
    }
    
    func numberOfDaysInWeek() -> Int {
        return calendar.maximumRangeOfUnit(.Weekday).length
    }
    
    func isPhone() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }
    
    func isPortrait() -> Bool {
        return UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
    }
    

    private func itemCircleImage(color: UIColor) -> UIImage {
        let itemDim = itemSize()
        let itemDimention = itemDim.height > itemDim.width ? itemDim.width - 10 : itemDim.height - 10
        let itemSz = CGSizeMake(itemDimention, itemDimention)
        let rect = CGRectMake(itemDim.width/2 - itemSz.width/2, itemDim.height/2 - itemSz.height/2, itemSz.width, itemSz.height)
        
        UIGraphicsBeginImageContextWithOptions(itemDim, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillEllipseInRect(context, rect)
        CGContextRestoreGState(context)
        let returnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return returnImage

    }

    private func dayOfWeekButton(index: Int) -> UIButton {
        let button = UIButton(type: .Custom)
        button.addTarget(self, action:#selector(CalendarWeekView.dayButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        if index != 0 && index != 6 {
            button.setTitleColor(self.buttonTextColor, forState: UIControlState.Normal)
        } else {
            button.setTitleColor(self.offButtonTextColor, forState: UIControlState.Normal)
        }
        button.setTitleColor(buttonSelectedTextColor, forState: .Selected)
        button.setTitleColor(buttonHighlightedTextColor, forState: .Highlighted)
        button.contentMode = UIViewContentMode.Center
        button.imageView?.contentMode = UIViewContentMode.Center
        button.backgroundColor = self.labelBackgroundColor
        button.titleLabel!.font = self.buttonFont
        button.tag = index
        return button
    }
}