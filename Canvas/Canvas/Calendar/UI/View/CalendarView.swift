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
    func calendarViewShouldHighlightDate(_ calendarView: CalendarView, date: Date) -> Bool
    func calendarViewShouldSelectDate(_ calendarView: CalendarView, date: Date) -> Bool
    func calendarViewDidSelectDate(_ calendarView: CalendarView, date: Date)
}

public protocol CalendarViewDataSource {
    func calendarViewNumberOfEventsForDate(_ calendarView: CalendarView, date: Date) -> Int
}

open class CalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CalendarCollectionViewDelegate {
    
    // ---------------------------------------------
    // MARK: - Constants
    // ---------------------------------------------
    let CALENDAR_VIEW_MONTH_HEADER_IDENTIFIER = "CALENDAR_VIEW_MONTH_VIEW_IDENTIFIER"
    let CALENDAR_VIEW_DAY_CELL_IDENTIFIER = "CALENDAR_VIEW_DAY_CELL_IDENTIFIER"
    
    // ---------------------------------------------
    // MARK: - Public Variables
    // ---------------------------------------------
    open var delegate: CalendarViewDelegate?
    open var dataSource: CalendarViewDataSource?
    
    open lazy var calendar: Calendar = {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale.current
        return calendar
        }()
    
    internal var fromDate = CalendarDate()
    internal var toDate = CalendarDate()
    internal var today: Date = Date()
    internal var selectedDate: CalendarDate?
    internal var daysInWeek: Int {
        get {
            return (self.calendar as NSCalendar).maximumRange(of: .weekday).length
        }
    }
    
    internal var daysOfWeekView: CalendarDaysOfWeekView = CalendarDaysOfWeekView(frame: CGRect.zero)
    
    internal var collectionView: CalendarCollectionView!
    
    internal var calCollectionViewLayout = CalendarCollectionViewLayout()

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM YYYY", options: 0, locale: Locale.current)
        return dateFormatter
    }()
    
    
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
    
    public init(frame: CGRect, calendar: Calendar, delegate: CalendarViewDelegate? = nil, dataSource: CalendarViewDataSource? = nil) {
        super.init(frame: frame)
        
        self.calendar = calendar
        self.delegate = delegate
        self.dataSource = dataSource
        initialize()
    }
    
    // Initial time range is 12 months prior and 6 months past the current month
    func initialize () {
        // setup today
        let todayDateComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Date())
        self.today = calendar.date(from: todayDateComponents)!
        
        let nowYearMonthComponents = (calendar as NSCalendar).components([.year, .month], from: Date())
        let now = calendar.date(from: nowYearMonthComponents)!
        
        resetToDate(now)
        resetFromDate(now)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarView.significantTimeChange(_:)), name: NSNotification.Name.UIApplicationSignificantTimeChange, object: nil)
        
        collectionView = CalendarCollectionView(frame: self.collectionViewFrame(), collectionViewLayout: calCollectionViewLayout)
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier:CALENDAR_VIEW_DAY_CELL_IDENTIFIER)
        collectionView.register(CalendarMonthHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CALENDAR_VIEW_MONTH_HEADER_IDENTIFIER)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.calendarDelegate = self
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
    }
    
    open override func layoutSubviews() {
        
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
            self.calCollectionViewLayout.prepare()
            self.collectionView!.contentOffset = beforeLayoutSubviewsContentOffset
        } else {
            self.addSubview(collectionView!)
            self.scrollToToday(false)
        }
    }
    
    // ---------------------------------------------
    // MARK: - UICollectionViewDataSource
    // ---------------------------------------------
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        let fromDate = self.fromDate.date(calendar)
        let toDate = self.toDate.date(calendar)
        return calendar.dateComponents([.month], from: fromDate, to: toDate).month!
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItemsInSection = daysInWeek * numberOfWeeksForMonthOfDate(dateForFirstDayInSection(section))
        return numberOfItemsInSection
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CALENDAR_VIEW_DAY_CELL_IDENTIFIER, for: indexPath) as! CalendarDayCell
        
        let firstDayInMonth = dateForFirstDayInSection(indexPath.section)
        var firstDayCalendarDate = CalendarDate()
        firstDayCalendarDate.populate(firstDayInMonth, calendar: calendar)
        let weekday = reorderedWeekday(calendar.dateComponents([.weekday], from: firstDayInMonth).weekday!)
        
        var addDateComponents = DateComponents()
        addDateComponents.day = indexPath.item - weekday
        let cellDate = (calendar as NSCalendar).date(byAdding: addDateComponents, to: firstDayInMonth, options: [])!
        
        var cellCalDate = CalendarDate()
        cellCalDate.populate(cellDate, calendar: calendar)
        cell.date = cellCalDate
        cell.day = cellCalDate.day
        
        var todayCalDate = CalendarDate()
        todayCalDate.populate(today, calendar: calendar)
        
        if !(firstDayCalendarDate.year == cellCalDate.year && firstDayCalendarDate.month == cellCalDate.month) {
            cell.cellState = .notMonth
            cell.setNeedsDisplay()
            return cell
        }
        
        if cellCalDate == selectedDate {
            cell.cellState = .selected
        } else if cellCalDate == todayCalDate {
            cell.cellState = .today
        } else {
            if calendar.isDateInWeekend(cellDate) {
                cell.cellState = .off
            } else {
                cell.cellState = .normal
            }
        }
        
        if let dataSource = self.dataSource {
            cell.eventCount = dataSource.calendarViewNumberOfEventsForDate(self, date: cellDate)
        }
        
        cell.setNeedsDisplay()
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let monthHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CALENDAR_VIEW_MONTH_HEADER_IDENTIFIER, for: indexPath) as? CalendarMonthHeaderView {
                
                let formattedDate = dateForFirstDayInSection(indexPath.section)
                var date = CalendarDate()
                date.populate(formattedDate, calendar: calendar)
                
                monthHeader.date = date
                monthHeader.dateLabel.text = CalendarView.dateFormatter.string(from: formattedDate).uppercased()
                
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
    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath)! as? CalendarDayCell {
            if cell.cellState == .notMonth {
                return false
            }
            
            if let _delegate = delegate {
                return _delegate.calendarViewShouldHighlightDate(self, date: cell.date!.date(calendar))
            }
            
        }
        
        return true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        cell.setNeedsDisplay()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        cell.setNeedsDisplay()
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath)! as? CalendarDayCell {
            if cell.cellState == .notMonth {
                return false
            }
            
            if let _delegate = delegate {
                return _delegate.calendarViewShouldSelectDate(self, date: cell.date!.date(calendar))
            }
            
        }
        
        return true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)! as? CalendarDayCell {
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
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calCollectionViewLayout.itemSize
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return calCollectionViewLayout.headerReferenceSize
    }
    
    // ---------------------------------------------
    // MARK: - CollectionView Helpers
    // ---------------------------------------------
    func indexPathForDate(_ date: Date) -> IndexPath {
        let monthSection = sectionForDate(date)
        let firstDayInMonth = dateForFirstDayInSection(monthSection)
        let weekday = reorderedWeekday((calendar as NSCalendar).components(.weekday, from: firstDayInMonth).weekday!)
        let dateItem = (calendar as NSCalendar).components(.day, from: firstDayInMonth, to: date, options: []).day! + weekday
        return IndexPath(row: dateItem, section: monthSection)
    }
    
    func sectionForDate(_ date: Date) -> Int {
        return (calendar as NSCalendar).components(.month, from: dateForFirstDayInSection(0), to:date, options: []).month!
    }
    
    func dateForFirstDayInSection(_ section: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = section
        return (calendar as NSCalendar).date(byAdding: dateComponents, to: fromDate.date(calendar), options: [])!
    }
    
    // ---------------------------------------------
    // MARK: - CalendarCollectionViewDelegate
    // ---------------------------------------------
    func collectionViewWillLayoutSubview(_ calendarCollectionView: CalendarCollectionView) {
        if collectionView!.contentOffset.y < 0.0 {
            appendPastDates()
        } else if (collectionView!.contentOffset.y > collectionView!.contentSize.height - collectionView!.bounds.height) {
            appendFutureDates()
        }
    }
    
    // ---------------------------------------------
    // MARK: - Scrolling Methods
    // ---------------------------------------------
    open func scrollToToday(_ animated: Bool) {
        self.scrollToDate(self.today, animated: animated)
    }
    
    func scrollToDate(_ date: Date, animated: Bool) {
        
        let dateYearMonthComponents = (calendar as NSCalendar).components([.year, .month], from: date)
        let month = calendar.date(from: dateYearMonthComponents)!
        
        resetToDate(month)
        resetFromDate(month)
        collectionView!.reloadData()
        calCollectionViewLayout.invalidateLayout()
        calCollectionViewLayout.prepare()
        
        restoreSelection()
        
        let dateIndexPath = indexPathForDate(date)
        let monthSection = sectionForDate(date)
        let dateItemRect = frameForItemAtIndexPath(dateIndexPath)
        let monthSectionHeaderRect = frameForHeaderForSection(monthSection)
        let delta = dateItemRect.maxY - monthSectionHeaderRect.midY
        let actualViewHeight = collectionView!.frame.height - collectionView!.contentInset.top - collectionView!.contentInset.bottom
        if delta <= actualViewHeight {
            self.scrollToTopOfSection(monthSection, animated:animated)
        } else {
            collectionView!.scrollToItem(at: dateIndexPath, at: UICollectionViewScrollPosition.bottom, animated: animated)
        }
    }
    
    func scrollToTopOfSection(_ section: Int, animated: Bool) {
        let headerRect = frameForHeaderForSection(section)
        let topOfHeader = CGPoint(x: 0, y: headerRect.origin.y - collectionView!.contentInset.top)
        collectionView.setContentOffset(topOfHeader, animated: animated)
    }
    
    open func selectDate(_ date: Date?) {
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
    fileprivate func daysOfWeekViewFrame() -> CGRect {
        var returnRect = bounds
        if isPhone() {
            returnRect.size.height = isPortrait() ? 22.0 : 26.0
        } else {
            returnRect.size.height = 36.0
        }
        
        return returnRect
    }
    
    fileprivate func collectionViewFrame() -> CGRect {
        let daysOfWeekViewHeight = daysOfWeekViewFrame().height
        
        var returnRect = self.bounds
        returnRect.origin.y += daysOfWeekViewHeight
        returnRect.size.height -= daysOfWeekViewHeight
        return returnRect
    }
    
    func frameForHeaderForSection(_ section: Int) -> CGRect {
        let indexPath = IndexPath(row: 0, section: section)
        let attrs = collectionView!.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: indexPath)!
        return attrs.frame
    }
    
    func frameForItemAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        let attrs = collectionView!.layoutAttributesForItem(at: indexPath)!
        return attrs.frame
    }
    
    // ---------------------------------------------
    // MARK: - Date Helpers
    // ---------------------------------------------
    func significantTimeChange(_ note: Notification) {
        let todayYearMonthDayComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Date())
        today = calendar.date(from: todayYearMonthDayComponents)!
        
        collectionView!.reloadData()
        restoreSelection()
    }
    
    func appendPastDates() {
        var dateComponents = DateComponents()
        dateComponents.month = -12
        shiftDatesByComponents(dateComponents)
    }
    
    func appendFutureDates() {
        var dateComponents = DateComponents()
        dateComponents.month = 12
        shiftDatesByComponents(dateComponents)
    }
    
    func shiftDatesByComponents(_ components: DateComponents) {
        if collectionView!.visibleCells.count == 0 {
            return
        }
        
        let fromIndexPath = collectionView!.indexPath(for: collectionView!.visibleCells[0])!
        let fromSection = fromIndexPath.section
        let fromSectionOfDate = dateForFirstDayInSection(fromSection)
        let fromAttrs = calCollectionViewLayout.layoutAttributesForItem(at: IndexPath(row: 0, section: fromSection))!
        let fromSectionOrigin = convert(fromAttrs.frame.origin, from: collectionView)

        var fromCalendarDate = CalendarDate()
        let fromDate = calendar.date(byAdding: components, to: self.fromDate.date(calendar))!
        fromCalendarDate.populate(fromDate, calendar: calendar)
        var toCalendarDate = CalendarDate()
        let toDate = calendar.date(byAdding: components, to: self.toDate.date(calendar))!
        toCalendarDate.populate(toDate, calendar: calendar)
        
        self.fromDate = fromCalendarDate
        self.toDate = toCalendarDate
        
        collectionView!.reloadData()
        calCollectionViewLayout.invalidateLayout()
        calCollectionViewLayout.prepare()
        restoreSelection()
        
        let toSection = sectionForDate(fromSectionOfDate)
        let toAttrs = calCollectionViewLayout.layoutAttributesForItem(at: IndexPath(row: 0, section: toSection))!
        let toSectionOrigin = convert(toAttrs.frame.origin, from: collectionView)

        let yOffset = collectionView!.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
        collectionView!.contentOffset = CGPoint(x: collectionView!.contentOffset.x, y: yOffset)
    }
    
    func dateIsWithinCurrentDateBounds(_ date: CalendarDate) -> Bool {
        return date > fromDate && date < toDate
    }
    
    func reorderedWeekday(_ weekday: Int) -> Int {
        // This is a bit of a hack but it's because Apple has issues with calendars.
        // The actual variable should be
//        var ordered = weekday - calendar.firstWeekday
        // but we need to modify the weekview because DateFormatter always returns week symbols starting with Sunday in order to do this correctly
        // This is good enough until we hear complaints about needing to support different firstWeekday for different countries
        var ordered = weekday - 1
        if ordered < 0 {
            ordered = daysInWeek + ordered
        }
        
        return ordered
    }
    
    func numberOfWeeksForMonthOfDate(_ date: Date) -> Int {
        let weekRange = (calendar as NSCalendar).range(of: .weekOfYear, in: .month, for: date)
        let weeksCount = weekRange.length
        return weeksCount
    }
    
    func resetToDate(_ referenceDate: Date) {
        // setup 12 months in the future
        var toDateComponents = DateComponents()
        toDateComponents.month = 12
        let toDate = (self.calendar as NSCalendar).date(byAdding: toDateComponents, to:referenceDate, options:NSCalendar.Options(rawValue: 0))!
        self.toDate.populate(toDate, calendar: calendar)
    }
    
    func resetFromDate(_ referenceDate: Date) {
        // setup 12 months prior to today
        var fromDateComponents = DateComponents()
        fromDateComponents.month = -12
        let fromDate = (self.calendar as NSCalendar).date(byAdding: fromDateComponents, to:referenceDate, options:NSCalendar.Options(rawValue: 0))!
        self.fromDate.populate(fromDate, calendar: calendar)
    }
    
    func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    func isPortrait() -> Bool {
        return UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
    }
    
    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    open func deselectSelection() {
        if let selectedDate = selectedDate {
            if dateIsWithinCurrentDateBounds(selectedDate) {
                
                var todayCalDate = CalendarDate()
                todayCalDate.populate(today, calendar: calendar)
                
                let selectedDate = selectedDate.date(calendar)
                let selectedCellIndexPath = indexPathForDate(selectedDate)
                collectionView!.deselectItem(at: selectedCellIndexPath, animated: false)
                if let selectedCell = collectionView!.cellForItem(at: selectedCellIndexPath) as? CalendarDayCell {
                    
                    if (self.selectedDate == todayCalDate) {
                        selectedCell.cellState = .today
                    } else {
                        if Calendar.current.isDateInWeekend(selectedDate) {
                            selectedCell.cellState = .off
                        } else {
                            selectedCell.cellState = .normal
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
                collectionView!.selectItem(at: selectedCellIndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
                if let selectedCell = collectionView!.cellForItem(at: selectedCellIndexPath) as? CalendarDayCell {
                    selectedCell.cellState = CalendarDayCellState.selected
                    selectedCell.setNeedsLayout()
                }
            }
        }
    }
    
    open func reloadData() {
        let contentOffset = collectionView.contentOffset
        collectionView!.reloadData()
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    
    open func reloadVisibleCells() {
        collectionView!.reloadItems(at: collectionView!.indexPathsForVisibleItems)
    }
    
}
