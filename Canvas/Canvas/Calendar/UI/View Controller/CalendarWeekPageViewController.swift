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
import CalendarKit

public protocol CalendarWeekPageViewControllerDelegate: class {
    func weekPageViewController(calendarWeekPageViewController: CalendarWeekPageViewController, daySelected day: NSDate)
    func weekPageViewController(calendarWeekPageViewController: CalendarWeekPageViewController, willTransitionToDay day: NSDate)
    func weekPageViewController(calendarWeekPageViewController: CalendarWeekPageViewController, didFinishAnimating finished: Bool, toDay day: NSDate, transitionCompleted completed: Bool)
}

public class CalendarWeekPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CalendarWeekDayViewControllerDelegate {

    // ---------------------------------------------
    // MARK: - Private Variables
    // ---------------------------------------------
    public var calendar: NSCalendar
    public var day: NSDate
    public weak var delegate: CalendarWeekPageViewControllerDelegate?
    
    // Page View Controller
    var pageViewController : UIPageViewController!

    // Data Structure
    var calendarEvents = [CalendarEvent]()

    // Temp Variables
    var transitionDay: NSDate?
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    public init(calendar: NSCalendar, day: NSDate, delegate: CalendarWeekPageViewControllerDelegate?) {
        self.calendar = calendar
        self.day = day
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let dayViewController = viewControllerForDay(day)
        let viewControllers = [dayViewController]
        pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        pageViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ---------------------------------------------
    // MARK: - Transition Methods
    // ---------------------------------------------
    func transitionToNextWeek() {
        transitionToDayOffset(numberOfDaysInWeek())
    }
    
    func transitionToPrevWeek() {
        transitionToDayOffset(-numberOfDaysInWeek())
    }
    
    func transitionToDayOffset(daysOffset: Int) {
        transitionToDay(dateMovedByDays(daysOffset))
    }
    
    private func transitionToDay(newDay: NSDate) {
        let compareDates = newDay.compare(day)
        if compareDates == .OrderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        var transitionDirection: UIPageViewControllerNavigationDirection = .Forward
        if compareDates == .OrderedAscending {
            transitionDirection = .Reverse
        } else {
            transitionDirection = .Forward
        }
        
        day = newDay
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let strongSelf = self {
                let dayViewController = strongSelf.viewControllerForDay(strongSelf.day)
                strongSelf.pageViewController.setViewControllers([dayViewController], direction: transitionDirection, animated: true, completion:nil)
            }
        }
        
    }
    
    // ---------------------------------------------
    // MARK: - UIPageViewControllerDataSource
    // ---------------------------------------------
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let prevDay = dateMovedByDays(-numberOfDaysInWeek())
        let dayViewController = viewControllerForDay(prevDay)
        return dayViewController
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let nextDay = dateMovedByDays(numberOfDaysInWeek())
        let dayViewController = viewControllerForDay(nextDay)
        return dayViewController
    }
    
    // ---------------------------------------------
    // MARK: - UIPageViewControllerDelegate
    // ---------------------------------------------
    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let nextVisibleDayViewController = pendingViewControllers.first as? CalendarWeekDayViewController {
            let compareDates = nextVisibleDayViewController.day.compare(day)
            if compareDates == .OrderedSame {
                // Dates are equal, no change is needed
                return
            }
            
            if compareDates == .OrderedAscending {
                transitionDay = dateMovedByDays(-numberOfDaysInWeek())
            } else {
                transitionDay = dateMovedByDays(numberOfDaysInWeek())
            }
            
            nextVisibleDayViewController.setDay(transitionDay!, animated: false)

            if let delegate = delegate {
                delegate.weekPageViewController(self, willTransitionToDay: transitionDay!)
            }
        }
    }
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            day = transitionDay!
        }
        
        if let delegate = delegate {
            delegate.weekPageViewController(self, didFinishAnimating: finished, toDay: day, transitionCompleted: completed)
        }
        
    }
    
    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    func viewControllerForDay(day: NSDate) -> CalendarWeekDayViewController {
        return CalendarWeekDayViewController(calendar: calendar, day: day, delegate: self)
    }
    
    func dateMovedByDays(daysToMove: Int) -> NSDate {
        let components = NSDateComponents()
        components.day = daysToMove
        return calendar.dateByAddingComponents(components, toDate:day, options: [])!
    }
    
    func numberOfDaysInWeek() -> Int {
        return calendar.maximumRangeOfUnit(.Weekday).length
    }
    
    func setDay(day: NSDate, animated: Bool) {
        if let currentWeekViewController = pageViewController.viewControllers?.first as? CalendarWeekDayViewController {
            if !currentWeekViewController.dateIsInWeek(day) {
                transitionToDay(day)
                return
            }
            
            self.day = day
            currentWeekViewController.setDay(self.day, animated: animated)
        }
    }
    
    func weekdayViewController(weekdayViewController: CalendarWeekDayViewController, selectedDate day: NSDate) {
        setDay(day, animated: true)
        if let delegate = delegate {
            delegate.weekPageViewController(self, daySelected: day)
        }
    }
    
}
