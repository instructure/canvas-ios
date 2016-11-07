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

public protocol CalendarViewDelegate {
    func calendarViewShouldHighlightDate(calendarView: CalendarView, date: NSDate) -> Bool
    func calendarViewShouldSelectDate(calendarView: CalendarView, date: NSDate) -> Bool
    func calendarViewDidSelectDate(calendarView: CalendarView, date: NSDate)
}

public protocol CalendarViewDataSource {
    func calendarViewColorsForMarkingDate(calendarView: CalendarView, date: NSDate) -> [UIColor]
}

public class CalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CalendarCollectionViewDelegate {
    
    // ---------------------------------------------
    // MARK: - Constants
    // ---------------------------------------------
    let CALENDAR_VIEW_MONTH_HEADER_IDENTIFIER = "CALENDAR_VIEW_MONTH_VIEW_IDENTIFIER"
    let CALENDAR_VIEW_DAY_CELL_IDENTIFIER = "CALENDAR_VIEW_DAY_CELL_IDENTIFIER"
    
    // ---------------------------------------------
    // MARK: - Public Variables
    // ---------------------------------------------
    public var delegate: CalendarViewDelegate?
    public var dataSource: CalendarViewDataSource?
    
    public lazy var calendar: NSCalendar = {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale.currentLocale()
        return calendar
        }()
    
    internal var fromDate = CalendarDate()
    internal var toDate = CalendarDate()
    internal var today: NSDate = NSDate()
    internal var selectedDate: CalendarDate?
    internal var daysInWeek: Int {
        get {
            return self.calendar.maximumRangeOfUnit(.Weekday).length
        }
    }
    
    internal var daysOfWeekView: CalendarDaysOfWeekView = CalendarDaysOfWeekView(frame: CGRectZero)
    
    internal var collectionView: CalendarCollectionView!
    
    internal var calCollectionViewLayout = CalendarCollectionViewLayout()
    
    
    // ---------------------------------------------
    // MARK: - LifeCycle
    // ---------------------------------------------
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public init(frame: CGRect, calendar: NSCalendar, delegate: CalendarViewDelegate? = nil, dataSource: CalendarViewDataSource? = nil) {
        super.init(frame: frame)
        
        self.calendar = calendar
        self.delegate = delegate
        self.dataSource = dataSource
        initialize()
    }
    
    // Initial time range is 12 months prior and 6 months past the current month
    func initialize () {
        // setup today
        let todayDateComponents = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
        self.today = calendar.dateFromComponents(todayDateComponents)!
        
        let nowYearMonthComponents = calendar.components([.Year, .Month], fromDate: NSDate())
        let now = calendar.dateFromComponents(nowYearMonthComponents)!
        
        resetToDate(now)
        resetFromDate(now)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarView.significantTimeChange(_:)), name: UIApplicationSignificantTimeChangeNotification, object: nil)
        
        collectionView = CalendarCollectionView(frame: self.collectionViewFrame(), collectionViewLayout: calCollectionViewLayout)
        collectionView.registerClass(CalendarDayCell.self, forCellWithReuseIdentifier:CALENDAR_VIEW_DAY_CELL_IDENTIFIER)
        collectionView.registerClass(CalendarMonthHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CALENDAR_VIEW_MONTH_HEADER_IDENTIFIER)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.calendarDelegate = self
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
    }
    
    public override func layoutSubviews() {
        
        let beforeLayoutSubviewsContentOffset = collectionView!.contentOffset
        
        super.layoutSubviews()
        
        self.daysOfWeekView.frame = daysOfWeekViewFrame()
        let daysOfWeekViewSuperView = daysOfWeekView.superview
        if daysOfWeekViewSuperView == nil {
            self.addSubview(self.daysOfWeekView)
        }
        
        self.collectionView!.frame = collectionViewFrame()
        
        calCollectionViewLayout.updateItemSize()
        calCollectionViewLayout.updateHeaderSize()
        calCollectionViewLayout.invalidateLayout()
        if let _ = collectionView!.superview {
            self.calCollectionViewLayout.invalidateLayout()
            self.calCollectionViewLayout.prepareLayout()
            self.collectionView!.contentOffset = beforeLayoutSubviewsContentOffset
        } else {
            self.addSubview(collectionView!)
            self.scrollToToday(false)
        }
    }
    
    // ---------------------------------------------
    // MARK: - UICollectionViewDataSource
    // ---------------------------------------------
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let fromNSDate = fromDate.date(calendar)
        let toNSDate = toDate.date(calendar)
        return calendar.components(.Month, fromDate: fromNSDate, toDate: toNSDate, options: []).month
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItemsInSection = daysInWeek * numberOfWeeksForMonthOfDate(dateForFirstDayInSection(section))
        return numberOfItemsInSection
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CALENDAR_VIEW_DAY_CELL_IDENTIFIER, forIndexPath: indexPath) as! CalendarDayCell
        
        let firstDayInMonth = dateForFirstDayInSection(indexPath.section)
        var firstDayCalendarDate = CalendarDate()
        firstDayCalendarDate.populate(firstDayInMonth, calendar: calendar)
        let weekday = reorderedWeekday(calendar.components(.Weekday, fromDate: firstDayInMonth).weekday)
        
        let addDateComponents = NSDateComponents()
        addDateComponents.day = indexPath.item - weekday
        let cellDate = calendar.dateByAddingComponents(addDateComponents, toDate: firstDayInMonth, options: [])!
        
        var cellCalDate = CalendarDate()
        cellCalDate.populate(cellDate, calendar: calendar)
        cell.date = cellCalDate
        cell.dateLabel.text = "\(cellCalDate.day)"
        
        var todayCalDate = CalendarDate()
        todayCalDate.populate(today, calendar: calendar)
        
        if !(firstDayCalendarDate.year == cellCalDate.year && firstDayCalendarDate.month == cellCalDate.month) {
            cell.cellState = .NotMonth
            cell.colorsToIndicate = nil
            cell.setNeedsDisplay()
            return cell
        }
        
        if cellCalDate == selectedDate {
            cell.cellState = .Selected
        } else if cellCalDate == todayCalDate {
            cell.cellState = .Today
        } else {
            if calendar.isDateInWeekend(cellDate) {
                cell.cellState = .Off
            } else {
                cell.cellState = .Normal
            }
        }
        
        if let dataSource = self.dataSource {
            cell.colorsToIndicate = dataSource.calendarViewColorsForMarkingDate(self, date: cellDate)
        }
        
        cell.setNeedsDisplay()
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let monthHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: CALENDAR_VIEW_MONTH_HEADER_IDENTIFIER, forIndexPath: indexPath) as? CalendarMonthHeaderView {
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMM YYYY", options: 0, locale: NSLocale.currentLocale())
                
                let formattedDate = dateForFirstDayInSection(indexPath.section)
                var date = CalendarDate()
                date.populate(formattedDate, calendar: calendar)
                
                monthHeader.date = date
                monthHeader.dateLabel.text = dateFormatter.stringFromDate(formattedDate).uppercaseString
                
                var todayCalDate = CalendarDate()
                todayCalDate.populate(today, calendar: calendar)
                monthHeader.currentMonth = (todayCalDate.month == date.month && todayCalDate.year == date.year)
                return monthHeader
            }
        }
        
        let reuseView : UICollectionReusableView! = nil
        return reuseView
    }
    
    // ---------------------------------------------
    // MARK: - UICollectionViewDelegate
    // ---------------------------------------------
    public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath)! as? CalendarDayCell {
            if cell.cellState == .NotMonth {
                return false
            }
            
            if let _delegate = delegate {
                return _delegate.calendarViewShouldHighlightDate(self, date: cell.date!.date(calendar))
            }
            
        }
        
        return true
    }
    
    public func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        cell.setNeedsDisplay()
    }
    
    public func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        cell.setNeedsDisplay()
    }
    
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath)! as? CalendarDayCell {
            if cell.cellState == .NotMonth {
                return false
            }
            
            if let _delegate = delegate {
                return _delegate.calendarViewShouldSelectDate(self, date: cell.date!.date(calendar))
            }
            
        }
        
        return true
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath)! as? CalendarDayCell {
            if let date = cell.date?.date(calendar) {
                selectDate(date)
                
                if let _delegate = delegate {
                    return _delegate.calendarViewDidSelectDate(self, date: date)
                }
            }
        }
    }
    
    // ---------------------------------------------
    // MARK: - UICollectionViewDelegateFlowLayout
    // ---------------------------------------------
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return calCollectionViewLayout.itemSize
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return calCollectionViewLayout.headerReferenceSize
    }
    
    // ---------------------------------------------
    // MARK: - CollectionView Helpers
    // ---------------------------------------------
    func indexPathForDate(date: NSDate) -> NSIndexPath {
        let monthSection = sectionForDate(date)
        let firstDayInMonth = dateForFirstDayInSection(monthSection)
        let weekday = reorderedWeekday(calendar.components(.Weekday, fromDate: firstDayInMonth).weekday)
        let dateItem = calendar.components(.Day, fromDate: firstDayInMonth, toDate: date, options: []).day + weekday
        return NSIndexPath(forRow: dateItem, inSection: monthSection)
    }
    
    func sectionForDate(date: NSDate) -> Int {
        return calendar.components(.Month, fromDate: dateForFirstDayInSection(0), toDate:date, options: []).month
    }
    
    func dateForFirstDayInSection(section: Int) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.month = section
        return calendar.dateByAddingComponents(dateComponents, toDate: fromDate.date(calendar), options: [])!
    }
    
    // ---------------------------------------------
    // MARK: - CalendarCollectionViewDelegate
    // ---------------------------------------------
    func collectionViewWillLayoutSubview(calendarCollectionView: CalendarCollectionView) {
        if collectionView!.contentOffset.y < 0.0 {
            appendPastDates()
        } else if (collectionView!.contentOffset.y > collectionView!.contentSize.height - CGRectGetHeight(collectionView!.bounds)) {
            appendFutureDates()
        }
    }
    
    // ---------------------------------------------
    // MARK: - Scrolling Methods
    // ---------------------------------------------
    public func scrollToToday(animated: Bool) {
        self.scrollToDate(self.today, animated: animated)
    }
    
    func scrollToDate(date: NSDate, animated: Bool) {
        
        let dateYearMonthComponents = calendar.components([.Year, .Month], fromDate: date)
        let month = calendar.dateFromComponents(dateYearMonthComponents)!
        
        resetToDate(month)
        resetFromDate(month)
        collectionView!.reloadData()
        calCollectionViewLayout.invalidateLayout()
        calCollectionViewLayout.prepareLayout()
        
        restoreSelection()
        
        let dateIndexPath = indexPathForDate(date)
        let monthSection = sectionForDate(date)
        let dateItemRect = frameForItemAtIndexPath(dateIndexPath)
        let monthSectionHeaderRect = frameForHeaderForSection(monthSection)
        let delta = CGRectGetMaxY(dateItemRect) - CGRectGetMidY(monthSectionHeaderRect)
        let actualViewHeight = CGRectGetHeight(collectionView!.frame) - collectionView!.contentInset.top - collectionView!.contentInset.bottom
        if delta <= actualViewHeight {
            self.scrollToTopOfSection(monthSection, animated:animated)
        } else {
            collectionView!.scrollToItemAtIndexPath(dateIndexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: animated)
        }
    }
    
    func scrollToTopOfSection(section: Int, animated: Bool) {
        let headerRect = frameForHeaderForSection(section)
        let topOfHeader = CGPointMake(0, headerRect.origin.y - collectionView!.contentInset.top)
        collectionView.setContentOffset(topOfHeader, animated: animated)
    }
    
    public func selectDate(date: NSDate?) {
        if let _date = date {
            var calDate = CalendarDate()
            calDate.populate(_date, calendar: calendar)
            if calDate == selectedDate {
                return
            }
            
            deselectSelection()
            selectedDate = CalendarDate()
            selectedDate?.populate(_date, calendar: calendar)
            restoreSelection()
        }
    }
    
    // ---------------------------------------------
    // MARK: - Frame Helpers
    // ---------------------------------------------
    private func daysOfWeekViewFrame() -> CGRect {
        var returnRect = bounds
        if isPhone() {
            returnRect.size.height = isPortrait() ? 22.0 : 26.0
        } else {
            returnRect.size.height = 36.0
        }
        
        return returnRect
    }
    
    private func collectionViewFrame() -> CGRect {
        let daysOfWeekViewHeight = CGRectGetHeight(daysOfWeekViewFrame())
        
        var returnRect = self.bounds
        returnRect.origin.y += daysOfWeekViewHeight
        returnRect.size.height -= daysOfWeekViewHeight
        return returnRect
    }
    
    func frameForHeaderForSection(section: Int) -> CGRect {
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        let attrs = collectionView!.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)!
        return attrs.frame
    }
    
    func frameForItemAtIndexPath(indexPath: NSIndexPath) -> CGRect {
        let attrs = collectionView!.layoutAttributesForItemAtIndexPath(indexPath)!
        return attrs.frame
    }
    
    // ---------------------------------------------
    // MARK: - Date Helpers
    // ---------------------------------------------
    func significantTimeChange(note: NSNotification) {
        let todayYearMonthDayComponents = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
        today = calendar.dateFromComponents(todayYearMonthDayComponents)!
        
        collectionView!.reloadData()
        restoreSelection()
    }
    
    func appendPastDates() {
        let dateComponents = NSDateComponents()
        dateComponents.month = -12
        shiftDatesByComponents(dateComponents)
    }
    
    func appendFutureDates() {
        let dateComponents = NSDateComponents()
        dateComponents.month = 12
        shiftDatesByComponents(dateComponents)
    }
    
    func shiftDatesByComponents(components: NSDateComponents) {
        if collectionView!.visibleCells().count == 0 {
            return
        }
        
        let fromIndexPath = collectionView!.indexPathForCell(collectionView!.visibleCells()[0])!
        let fromSection = fromIndexPath.section
        let fromSectionOfDate = dateForFirstDayInSection(fromSection)
        let fromAttrs = calCollectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: fromSection))!
        let fromSectionOrigin = convertPoint(fromAttrs.frame.origin, fromView: collectionView)

        var fromCalendarDate = CalendarDate()
        let fromNSDate = calendar.dateByAddingComponents(components, toDate: fromDate.date(calendar), options: [])!
        fromCalendarDate.populate(fromNSDate, calendar: calendar)
        var toCalendarDate = CalendarDate()
        let toNSDate = calendar.dateByAddingComponents(components, toDate: toDate.date(calendar), options: [])!
        toCalendarDate.populate(toNSDate, calendar: calendar)
        
        fromDate = fromCalendarDate
        toDate = toCalendarDate
        
        collectionView!.reloadData()
        calCollectionViewLayout.invalidateLayout()
        calCollectionViewLayout.prepareLayout()
        restoreSelection()
        
        let toSection = sectionForDate(fromSectionOfDate)
        let toAttrs = calCollectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: toSection))!
        let toSectionOrigin = convertPoint(toAttrs.frame.origin, fromView: collectionView)

        let yOffset = collectionView!.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
        collectionView!.contentOffset = CGPointMake(collectionView!.contentOffset.x, yOffset)
    }
    
    func dateIsWithinCurrentDateBounds(date: CalendarDate) -> Bool {
        return date > fromDate && date < toDate
    }
    
    func reorderedWeekday(weekday: Int) -> Int {
        // This is a bit of a hack but it's because Apple has issues with calendars.
        // The actual variable should be
//        var ordered = weekday - calendar.firstWeekday
        // but we need to modify the weekview because NSDateFormatter always returns week symbols starting with Sunday in order to do this correctly
        // This is good enough until we hear complaints about needing to support different firstWeekday for different countries
        var ordered = weekday - 1
        if ordered < 0 {
            ordered = daysInWeek + ordered
        }
        
        return ordered
    }
    
    func numberOfWeeksForMonthOfDate(date: NSDate) -> Int {
        let weekRange = calendar.rangeOfUnit(.WeekOfYear, inUnit: .Month, forDate: date)
        let weeksCount = weekRange.length
        return weeksCount
    }
    
    func resetToDate(referenceDate: NSDate) {
        // setup 12 months in the future
        let toDateComponents = NSDateComponents()
        toDateComponents.month = 12
        let toNSDate = self.calendar.dateByAddingComponents(toDateComponents, toDate:referenceDate, options:NSCalendarOptions(rawValue: 0))!
        toDate.populate(toNSDate, calendar: calendar)
    }
    
    func resetFromDate(referenceDate: NSDate) {
        // setup 12 months prior to today
        let fromDateComponents = NSDateComponents()
        fromDateComponents.month = -12
        let fromNSDate = self.calendar.dateByAddingComponents(fromDateComponents, toDate:referenceDate, options:NSCalendarOptions(rawValue: 0))!
        fromDate.populate(fromNSDate, calendar: calendar)
    }
    
    func isPhone() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }
    
    func isPortrait() -> Bool {
        return UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
    }
    
    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    public func deselectSelection() {
        if let selectedDate = selectedDate {
            if dateIsWithinCurrentDateBounds(selectedDate) {
                
                var todayCalDate = CalendarDate()
                todayCalDate.populate(today, calendar: calendar)
                
                let selectedNSDate = selectedDate.date(calendar)
                let selectedCellIndexPath = indexPathForDate(selectedNSDate)
                collectionView!.deselectItemAtIndexPath(selectedCellIndexPath, animated: false)
                if let selectedCell = collectionView!.cellForItemAtIndexPath(selectedCellIndexPath) as? CalendarDayCell {
                    
                    if (selectedDate == todayCalDate) {
                        selectedCell.cellState = .Today
                    } else {
                        let weekday = calendar.components(.Weekday, fromDate: selectedNSDate).weekday
                        if (weekday == 1 || weekday == 7) {
                            selectedCell.cellState = .Off
                        } else {
                            selectedCell.cellState = .Normal
                        }
                    }
                    
                    selectedCell.setNeedsLayout()
                }
            }
        }
    }
    
    func restoreSelection() {
        if let selectedDate = selectedDate {
            if dateIsWithinCurrentDateBounds(selectedDate) {
                let selectedCellIndexPath = indexPathForDate(selectedDate.date(calendar))
                collectionView!.selectItemAtIndexPath(selectedCellIndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
                if let selectedCell = collectionView!.cellForItemAtIndexPath(selectedCellIndexPath) as? CalendarDayCell {
                    selectedCell.cellState = CalendarDayCellState.Selected
                    selectedCell.setNeedsLayout()
                }
            }
        }
    }
    
    public func reloadData() {
        let contentOffset = collectionView.contentOffset
        collectionView!.reloadData()
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    
    public func reloadVisibleCells() {
        collectionView!.reloadItemsAtIndexPaths(collectionView!.indexPathsForVisibleItems())
    }
    
}